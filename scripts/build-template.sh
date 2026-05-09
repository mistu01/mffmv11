#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/dist}"
VERSION="${VERSION:-}"
VERSION_CODE="${VERSION_CODE:-}"
ZIP_PREFIX="${ZIP_PREFIX:-MFFM_Template}"

usage() {
  cat <<'EOF'
Usage: scripts/build-template.sh [--version VERSION] [--version-code CODE] [--out-dir DIR]

Builds the flashable MFFM template zip in a clean staging directory and stamps
module.prop with release version metadata.

Defaults:
  VERSION       tag name without leading "v" on tag builds, otherwise UTC YYYY.MM.DD
  VERSION_CODE derived from VERSION when possible, otherwise UTC YYYYMMDD
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    --version-code)
      VERSION_CODE="${2:-}"
      shift 2
      ;;
    --out-dir)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

default_version() {
  if [ "${GITHUB_REF_TYPE:-}" = "tag" ] && [ -n "${GITHUB_REF_NAME:-}" ]; then
    printf '%s\n' "${GITHUB_REF_NAME#v}"
  else
    date -u +%Y.%m.%d
  fi
}

derive_version_code() {
  local version major minor patch
  version="${1#v}"

  if [[ "$version" =~ ^([0-9]{4})[.-]([0-9]{2})[.-]([0-9]{2})$ ]]; then
    printf '%s%s%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
    return 0
  fi

  if [[ "$version" =~ ^([0-9]+)[.]([0-9]+)[.]([0-9]+)$ ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
    printf '%d\n' $((10#$major * 1000000 + 10#$minor * 1000 + 10#$patch))
    return 0
  fi

  date -u +%Y%m%d
}

set_prop() {
  local file key value escaped
  file="$1"
  key="$2"
  value="$3"
  escaped="$(printf '%s' "$value" | sed 's/[\/&]/\\&/g')"

  if grep -q "^$key=" "$file"; then
    sed -i "s/^$key=.*/$key=$escaped/" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >> "$file"
  fi
}

require_file() {
  [ -e "$ROOT_DIR/$1" ] || {
    echo "Missing required package path: $1" >&2
    exit 1
  }
}

VERSION="${VERSION:-$(default_version)}"
VERSION="${VERSION#v}"
VERSION_CODE="${VERSION_CODE:-$(derive_version_code "$VERSION")}"

case "$VERSION" in
  ''|*[!A-Za-z0-9._-]*)
    echo "Invalid VERSION: $VERSION" >&2
    exit 1
    ;;
esac

case "$VERSION_CODE" in
  ''|*[!0-9]*)
    echo "VERSION_CODE must be numeric: $VERSION_CODE" >&2
    exit 1
    ;;
esac

require_file "META-INF"
require_file "module.prop"
require_file "customize.sh"
require_file "LICENSE"

mkdir -p "$OUT_DIR"
STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGE_DIR"' EXIT

mkdir -p "$STAGE_DIR/Files"
if [ -d "$ROOT_DIR/Files" ]; then
  cp -R "$ROOT_DIR/Files/." "$STAGE_DIR/Files/"
fi
rm -f "$STAGE_DIR/Files/.gitkeep"

cp -R "$ROOT_DIR/META-INF" "$STAGE_DIR/META-INF"
cp "$ROOT_DIR/module.prop" "$STAGE_DIR/module.prop"
cp "$ROOT_DIR/customize.sh" "$STAGE_DIR/customize.sh"
cp "$ROOT_DIR/LICENSE" "$STAGE_DIR/LICENSE"

set_prop "$STAGE_DIR/module.prop" "id" "mffm11"
set_prop "$STAGE_DIR/module.prop" "name" "[MFFMv11]"
set_prop "$STAGE_DIR/module.prop" "version" "$VERSION"
set_prop "$STAGE_DIR/module.prop" "versionCode" "$VERSION_CODE"
set_prop "$STAGE_DIR/module.prop" "description" "MFFM template release $VERSION. Compatible with Magisk, KernelSU/KernelSU Next, and APatch; KSU/APatch system mounting may require an active mount metamodule."

ZIP_NAME="${ZIP_PREFIX}_v${VERSION}[MFFMv11].zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"
rm -f "$ZIP_PATH"

if command -v zip >/dev/null 2>&1; then
  (
    cd "$STAGE_DIR"
    zip -r "$ZIP_PATH" Files META-INF module.prop customize.sh LICENSE -x "Files/.gitkeep" >/dev/null
  )
else
  PYTHON_BIN=""
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="python3"
  elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
  fi

  [ -n "$PYTHON_BIN" ] || {
    echo "Neither zip nor python is available for archive creation." >&2
    exit 1
  }

  PY_STAGE_DIR="$STAGE_DIR"
  PY_ZIP_PATH="$ZIP_PATH"
  if command -v cygpath >/dev/null 2>&1; then
    PY_STAGE_DIR="$(cygpath -w "$STAGE_DIR")"
    PY_ZIP_PATH="$(cygpath -w "$ZIP_PATH")"
  fi

  STAGE_DIR="$PY_STAGE_DIR" ZIP_PATH="$PY_ZIP_PATH" "$PYTHON_BIN" - <<'PY'
import os
import zipfile

stage_dir = os.environ["STAGE_DIR"]
zip_path = os.environ["ZIP_PATH"]
items = ["Files", "META-INF", "module.prop", "customize.sh", "LICENSE"]
dir_entries = [
    "Files/",
    "META-INF/",
    "META-INF/com/",
    "META-INF/com/google/",
    "META-INF/com/google/android/",
]

with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as archive:
    for entry in dir_entries:
        archive.writestr(entry, b"")

    for item in items:
        absolute = os.path.join(stage_dir, item)
        if os.path.isdir(absolute):
            for root, _, files in os.walk(absolute):
                for filename in files:
                    full_path = os.path.join(root, filename)
                    relative = os.path.relpath(full_path, stage_dir).replace(os.sep, "/")
                    if relative == "Files/.gitkeep":
                        continue
                    archive.write(full_path, relative)
        elif os.path.isfile(absolute):
            archive.write(absolute, item)
PY
fi

[ -f "$ZIP_PATH" ] || {
  echo "Build completed but zip was not found at: $ZIP_PATH" >&2
  echo "Contents of output directory:" >&2
  find "$OUT_DIR" -maxdepth 1 -type f -print >&2
  exit 1
}

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    printf 'version=%s\n' "$VERSION"
    printf 'version_code=%s\n' "$VERSION_CODE"
    printf 'zip_name=%s\n' "$ZIP_NAME"
    printf 'zip_path=%s\n' "$ZIP_PATH"
  } >> "$GITHUB_OUTPUT"
fi

printf 'Built %s\n' "$ZIP_PATH"
printf 'Version: %s\n' "$VERSION"
printf 'VersionCode: %s\n' "$VERSION_CODE"
