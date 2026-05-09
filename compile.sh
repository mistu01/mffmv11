#!/usr/bin/env bash
set -euo pipefail

escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

escape_ps_single_quote() {
  printf '%s' "$1" | sed "s/'/''/g"
}

read -r -p "Enter name: " NAME
[ -n "$NAME" ] || {
  echo "Name cannot be empty." >&2
  exit 1
}

mkdir -p Files

DATE="$(date +%Y%m%d)"
VERSION="$(date +%Y.%m.%d)"
MODIFIED_NAME="[MFFMv11] $NAME"
DESCRIPTION="Replaces the Android default Roboto font family with \"$NAME\". Compatible with Magisk, KernelSU/KernelSU Next, and APatch; KSU/APatch system mounting may require an active mount metamodule."

sed -i "s/^\(id=\).*/\1mffm11/" module.prop
sed -i "s/^\(name=\).*/\1$(escape_sed_replacement "$MODIFIED_NAME")/" module.prop
sed -i "s/^\(version=\).*/\1$VERSION/" module.prop
sed -i "s/^\(versionCode=\).*/\1$DATE/" module.prop
sed -i "s/^\(description=\).*/\1$(escape_sed_replacement "$DESCRIPTION")/" module.prop

ZIP_NAME="$(printf '%s' "$NAME" | tr -d '[:space:]' | tr -cd 'A-Za-z0-9._-')"
[ -n "$ZIP_NAME" ] || ZIP_NAME="MFFM"
ARCHIVE_NAME="${ZIP_NAME}_v${DATE}[MFFMv11].zip"

FILES="Files META-INF module.prop customize.sh LICENSE"

if command -v zip >/dev/null 2>&1; then
  zip -r "$ARCHIVE_NAME" $FILES -x "Files/.gitkeep"
elif command -v powershell.exe >/dev/null 2>&1; then
  ARCHIVE_NAME_PS="$(escape_ps_single_quote "$ARCHIVE_NAME")"
  powershell.exe -NoProfile -Command "\
\$ErrorActionPreference = 'Stop'; \
Add-Type -AssemblyName System.IO.Compression; \
Add-Type -AssemblyName System.IO.Compression.FileSystem; \
\$archive = [IO.Path]::GetFullPath('$ARCHIVE_NAME_PS'); \
if ([IO.File]::Exists(\$archive)) { [IO.File]::Delete(\$archive) } \
\$zip = [System.IO.Compression.ZipFile]::Open(\$archive, [System.IO.Compression.ZipArchiveMode]::Create); \
\$dirEntries = @('Files/','META-INF/','META-INF/com/','META-INF/com/google/','META-INF/com/google/android/'); \
foreach (\$dirEntry in \$dirEntries) { [void]\$zip.CreateEntry(\$dirEntry) } \
\$root = (Get-Location).Path.TrimEnd('\') + '\'; \
\$items = @('Files','META-INF','module.prop','customize.sh','LICENSE'); \
foreach (\$item in \$items) { \
  if (Test-Path -LiteralPath \$item -PathType Container) { \
    Get-ChildItem -LiteralPath \$item -Recurse -Force | Where-Object { -not \$_.PSIsContainer } | ForEach-Object { \
      \$rel = \$_.FullName.Substring(\$root.Length).Replace('\','/'); \
      if (\$rel -eq 'Files/.gitkeep') { return } \
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(\$zip, \$_.FullName, \$rel, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null; \
    } \
  } elseif (Test-Path -LiteralPath \$item -PathType Leaf) { \
    \$full = [IO.Path]::GetFullPath(\$item); \
    \$rel = \$full.Substring(\$root.Length).Replace('\','/'); \
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(\$zip, \$full, \$rel, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null; \
  } \
} \
\$zip.Dispose();"
else
  echo "Neither zip nor powershell.exe Compress-Archive is available." >&2
  exit 1
fi

echo "Created archive: $ARCHIVE_NAME"
