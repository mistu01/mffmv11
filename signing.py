"""
signing.py - Auto-downloads ZipSignerust, generates an RSA key pair, and signs
Magisk module ZIPs with ZipSignerust.

Designed to work identically on:
  - Windows / PowerShell
  - WSL / Linux / macOS

It is imported by compile.py and update.py and can also be run standalone:

    python signing.py                    # generate keys + download tool
    python signing.py <zip>              # sign <zip> in place
    python signing.py <zip> <out.zip>    # sign to a separate output file

Requires the optional `cryptography` package for key generation:
    pip install cryptography

If `cryptography` is not installed, ZipSignerust falls back to its bundled
development key (the module will be signed but NOT authentic).
"""

from __future__ import annotations

import os
import sys
import stat
import json
import shutil
import platform
import subprocess
import urllib.request
import urllib.error
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

SCRIPT_DIR = Path(__file__).resolve().parent

#: Root directory where the ZipSignerust binary is cached.
TOOLS_DIR = SCRIPT_DIR / "tools"

#: Directory where the generated signing key pair is stored.
KEYS_DIR = SCRIPT_DIR / "keys"

#: PEM-encoded PKCS#8 RSA private key (consumed by ZipSignerust --private-key).
PRIVATE_KEY_PATH = KEYS_DIR / "mffm_private.pem"

#: PEM-encoded X.509 certificate wrapping the matching public key
#: (consumed by ZipSignerust --public-key).
PUBLIC_KEY_PATH = KEYS_DIR / "mffm_public.pem"

#: ZipSignerust release tag to download from.
ZIPSIGNERUST_TAG = "latest"

#: GitHub base URL for release assets.
ZIPSIGNERUST_BASE = (
    "https://github.com/MrCarb0n/zipsignerust/releases/download/"
    + ZIPSIGNERUST_TAG
)

#: RSA key size (bits). ZipSignerust verifies with RSA_PKCS1_2048_8192_SHA256.
RSA_KEY_BITS = 2048

#: Certificate validity horizon (years from generation).
CERT_VALID_YEARS = 30

#: Subject string embedded in the generated certificate.
CERT_SUBJECT = "/C=BD/O=MFFM/CN=MFFM Signing Certificate"


# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------

def _is_wsl() -> bool:
    """Return True when running inside Windows Subsystem for Linux."""
    if platform.system() != "Linux":
        return False
    try:
        release = platform.uname().release.lower()
        return "microsoft" in release or "wsl" in release
    except Exception:
        return False


def _asset_name() -> str:
    """Return the ZipSignerust release-asset name for the current platform."""
    machine = platform.machine().lower()
    if machine in ("x86_64", "amd64"):
        arch = "x64"
    elif machine in ("aarch64", "arm64"):
        arch = "arm64"
    elif machine in ("armv7l", "armv6l"):
        arch = "armv7"
    else:
        arch = "x64"  # sensible default

    if sys.platform == "win32" or os.name == "nt":
        return f"zipsignerust-windows-{arch}.exe"
    # Linux (native or WSL) and macOS all use the linux asset.
    return f"zipsignerust-linux-{arch}"


def binary_path() -> Path:
    """Resolved path to the cached ZipSignerust executable."""
    return TOOLS_DIR / _asset_name()


# ---------------------------------------------------------------------------
# Tool download
# ---------------------------------------------------------------------------

def _download(url: str, dest: Path, timeout: int = 60) -> None:
    """Download ``url`` to ``dest`` using urllib with a progress line."""
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(dest.suffix + ".part")
    print(f"  Downloading {url}")
    req = urllib.request.Request(url, headers={"User-Agent": "mffmv11-signing"})
    with urllib.request.urlopen(req, timeout=timeout) as resp, open(tmp, "wb") as out:
        total = resp.length or 0
        done = 0
        chunk = 64 * 1024
        while True:
            buf = resp.read(chunk)
            if not buf:
                break
            out.write(buf)
            done += len(buf)
            if total:
                pct = done * 100 // total
                sys.stdout.write(f"\r  {done // 1024} KiB ({pct}%)")
                sys.stdout.flush()
    print()  # newline after progress
    tmp.replace(dest)


def _make_executable(path: Path) -> None:
    """Ensure ``path`` is executable on POSIX systems."""
    if os.name == "nt":
        return
    mode = os.stat(path).st_mode
    os.chmod(path, mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def ensure_tool(install_subsystem: str | None = None) -> Path | None:
    """Ensure the ZipSignerust binary is present; download it if missing.

    Returns the path to the binary on success, or ``None`` if the download
    failed (signing is then skipped gracefully).
    """
    target = binary_path()
    if target.exists() and target.stat().st_size > 0:
        _make_executable(target)
        return target

    asset = _asset_name()
    url = f"{ZIPSIGNERUST_BASE}/{asset}"
    print("  ZipSignerust binary not found - downloading...")
    try:
        _download(url, target)
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        print(f"  [!] Failed to download ZipSignerust: {exc}")
        print("      Signing will be skipped. You can download it manually from:")
        print(f"      {url}")
        print(f"      and place it at: {target}")
        return None

    _make_executable(target)

    # Sanity check the binary actually runs.
    ok = _verify_tool_runs(target)
    if not ok:
        print(f"  [!] Downloaded binary at {target} did not execute.")
        print("      Signing will be skipped.")
        return None

    print(f"  ZipSignerust ready at: {target}")
    return target


def _verify_tool_runs(exe: Path) -> bool:
    """Return True if the binary prints version info."""
    try:
        proc = subprocess.run(
            [str(exe), "-V"],
            capture_output=True,
            text=True,
            timeout=20,
        )
        return proc.returncode == 0 or "ZipSigner" in (proc.stdout + proc.stderr)
    except Exception:
        return False


# ---------------------------------------------------------------------------
# Key pair generation
# ---------------------------------------------------------------------------

def ensure_keys() -> bool:
    """Generate the RSA key pair if it does not already exist.

    Returns True if usable keys are available (custom keys), False otherwise.
    """
    if PRIVATE_KEY_PATH.exists() and PUBLIC_KEY_PATH.exists():
        return True

    print("  Signing key pair not found - generating new RSA-2048 key pair...")
    try:
        from cryptography import x509
        from cryptography.hazmat.primitives import hashes, serialization
        from cryptography.hazmat.primitives.asymmetric import rsa
        from cryptography.x509.oid import NameOID
        import datetime
    except ImportError:
        print("  [!] 'cryptography' package not installed.")
        print("      Install it with: pip install cryptography")
        print("      ZipSignerust will fall back to its bundled development key")
        print("      (the module will be signed but NOT authentic).")
        return False

    KEYS_DIR.mkdir(parents=True, exist_ok=True)

    private_key = rsa.generate_private_key(public_exponent=65537, key_size=RSA_KEY_BITS)

    # Build a self-signed certificate so ZipSignerust can read not_before for
    # its reproducible timestamp.
    name = x509.Name(
        [
            x509.NameAttribute(NameOID.COUNTRY_NAME, "BD"),
            x509.NameAttribute(NameOID.ORGANIZATION_NAME, "MFFM"),
            x509.NameAttribute(NameOID.COMMON_NAME, "MFFM Signing Certificate"),
        ]
    )
    now = datetime.datetime.now(datetime.timezone.utc)
    builder = (
        x509.CertificateBuilder()
        .subject_name(name)
        .issuer_name(name)
        .public_key(private_key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(now - datetime.timedelta(minutes=1))
        .not_valid_after(now + datetime.timedelta(days=365 * CERT_VALID_YEARS))
        .add_extension(
            x509.BasicConstraints(ca=False, path_length=None), critical=True
        )
    )
    certificate = builder.sign(private_key, hashes.SHA256())

    # Private key -> PEM PKCS#8 (unencrypted; ZipSignerust reads PKCS#8).
    PRIVATE_KEY_PATH.write_bytes(
        private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )
    )

    # Public key -> PEM X.509 certificate.
    PUBLIC_KEY_PATH.write_bytes(certificate.public_bytes(serialization.Encoding.PEM))

    # Restrict private-key permissions on POSIX.
    if os.name != "nt":
        os.chmod(PRIVATE_KEY_PATH, stat.S_IRUSR | stat.S_IWUSR)

    print(f"  Private key: {PRIVATE_KEY_PATH}")
    print(f"  Public cert: {PUBLIC_KEY_PATH}")
    print("  Keep the private key safe - it authenticates your modules.")
    return True


# ---------------------------------------------------------------------------
# Signing
# ---------------------------------------------------------------------------

def sign_zip(
    archive_path: str | os.PathLike,
    output_path: str | os.PathLike | None = None,
    *,
    overwrite: bool = True,
) -> bool:
    """Sign ``archive_path`` using ZipSignerust.

    Parameters
    ----------
    archive_path:
        Path to the unsigned ZIP to sign.
    output_path:
        Where to write the signed ZIP. If ``None`` the archive is signed
        in place (ZipSignerust's ``--inplace`` mode, leaves a ``.bak``).
    overwrite:
        Passed as ``-f`` to ZipSignerust when signing to a separate output.

    Returns
    -------
    bool
        True if signing succeeded, False if it was skipped or failed.
    """
    archive = Path(archive_path)
    if not archive.exists():
        print(f"  [!] Archive not found for signing: {archive}")
        return False

    exe = ensure_tool()
    if exe is None:
        print("  [!] ZipSignerust unavailable - skipping signing.")
        return False

    have_keys = ensure_keys()

    cmd: list[str] = [str(exe), "-q", "sign"]
    inplace = output_path is None
    if inplace:
        cmd.append("-i")
    elif overwrite:
        cmd.append("-f")

    cmd.append(str(archive))
    if not inplace and output_path is not None:
        cmd.append(str(output_path))

    if have_keys:
        cmd += ["-k", str(PRIVATE_KEY_PATH), "-p", str(PUBLIC_KEY_PATH)]

    print(f"  Signing: {'(in-place) ' if inplace else ''}{archive.name}")
    if not have_keys:
        print("  (using ZipSignerust bundled development key - NOT authentic)")

    try:
        proc = subprocess.run(cmd, capture_output=True, text=True)
    except Exception as exc:
        print(f"  [!] Failed to invoke ZipSignerust: {exc}")
        return False

    if proc.returncode != 0:
        print("  [!] ZipSignerust signing failed:")
        if proc.stdout.strip():
            print(proc.stdout.strip())
        if proc.stderr.strip():
            print(proc.stderr.strip())
        return False

    # Clean up the .bak created by in-place signing.
    if inplace:
        bak = Path(str(archive) + ".bak")
        if bak.exists():
            try:
                bak.unlink()
            except OSError:
                pass

    print("  Archive signed successfully.")
    return True


def verify_zip(archive_path: str | os.PathLike) -> bool:
    """Verify a signed ZIP. Returns True if the signature is valid."""
    archive = Path(archive_path)
    if not archive.exists():
        print(f"  [!] Archive not found for verification: {archive}")
        return False

    exe = ensure_tool()
    if exe is None:
        return False

    cmd = [str(exe), "-q", "verify", str(archive)]
    if PRIVATE_KEY_PATH.exists() and PUBLIC_KEY_PATH.exists():
        cmd += ["-p", str(PUBLIC_KEY_PATH)]

    try:
        proc = subprocess.run(cmd, capture_output=True, text=True)
    except Exception as exc:
        print(f"  [!] Failed to invoke ZipSignerust verify: {exc}")
        return False

    return proc.returncode == 0


# ---------------------------------------------------------------------------
# Standalone CLI
# ---------------------------------------------------------------------------

def _main(argv: list[str]) -> int:
    print("========================================")
    print("     MFFMv11 Module Signing")
    print("========================================\n")

    if len(argv) >= 2:
        archive = Path(argv[1])
        output = Path(argv[2]) if len(argv) >= 3 else None
        ok = sign_zip(archive, output)
        return 0 if ok else 1

    # No arguments -> prepare keys + tool only.
    ensure_keys()
    ensure_tool()
    print("\nDone. Signing keys and tool are ready.")
    return 0


if __name__ == "__main__":
    sys.exit(_main(sys.argv))
