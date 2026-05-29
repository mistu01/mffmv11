#!/system/bin/sh
#
# MFFM v11 module installer.
# Compatible with Magisk, KernelSU/KernelSU Next, and APatch module installers.

[ "$MFFM_DEBUG" = "1" ] && set -x

if ! command -v ui_print >/dev/null 2>&1; then
  ui_print() { echo "$1"; }
fi

umount() {
  local path
  for path in "$@"; do
    [ -n "$path" ] || continue
    
    # Try unmounting globally using nsenter (mount namespace of PID 1)
    if command -v nsenter >/dev/null 2>&1; then
      nsenter -t 1 -m -- umount "$path" >/dev/null 2>&1 || \
      nsenter -t 1 -m -- umount -l "$path" >/dev/null 2>&1 || \
      nsenter -t 1 -m -- busybox umount -l "$path" >/dev/null 2>&1 || \
      nsenter -t 1 -m -- toybox umount -l "$path" >/dev/null 2>&1
    fi
    if [ -f /system/bin/toybox ]; then
      /system/bin/toybox nsenter -t 1 -m -- umount "$path" >/dev/null 2>&1 || \
      /system/bin/toybox nsenter -t 1 -m -- umount -l "$path" >/dev/null 2>&1 || \
      /system/bin/toybox nsenter -t 1 -m -- busybox umount -l "$path" >/dev/null 2>&1 || \
      /system/bin/toybox nsenter -t 1 -m -- toybox umount -l "$path" >/dev/null 2>&1
    fi

    # Try local/current namespace unmounting as fallback
    command umount "$path" >/dev/null 2>&1 || \
    command umount -l "$path" >/dev/null 2>&1 || \
    busybox umount -l "$path" >/dev/null 2>&1 || \
    toybox umount -l "$path" >/dev/null 2>&1 || \
    /system/bin/umount "$path" >/dev/null 2>&1 || \
    /system/bin/umount -l "$path" >/dev/null 2>&1 || \
    true
  done
  return 0
}

mffm_abort() {
  if command -v abort >/dev/null 2>&1; then
    abort "$1"
  fi
  ui_print "$1"
  exit 1
}

is_true() {
  [ "$1" = "true" ] || [ "$1" = "1" ]
}

read_prop_value() {
  local key file
  key="$1"
  file="$2"
  [ -f "$file" ] || return 1
  sed -n "s/^$key=//p" "$file" | head -n 1
}

first_dir() {
  local dir
  for dir in "$@"; do
    [ -n "$dir" ] && [ -d "$dir" ] && {
      echo "$dir"
      return 0
    }
  done
  return 1
}

find_magisk_mirror() {
  local magisk_path mirror

  if command -v magisk >/dev/null 2>&1; then
    magisk_path="$(magisk --path 2>/dev/null)"
    if [ -n "$magisk_path" ] && [ -d "$magisk_path/.magisk/mirror/system" ]; then
      echo "$magisk_path/.magisk/mirror"
      return 0
    fi
  fi

  for mirror in /sbin/.magisk/mirror /debug_ramdisk/.magisk/mirror /dev/*/.magisk/mirror; do
    [ -d "$mirror/system" ] && {
      echo "$mirror"
      return 0
    }
  done

  return 1
}

has_file_match() {
  local dir pattern
  dir="$1"
  pattern="$2"
  [ -d "$dir" ] || return 1
  [ -n "$(find "$dir" -maxdepth 1 -type f -name "$pattern" 2>/dev/null | head -n 1)" ]
}

copy_matches() {
  local src_dir pattern dest_dir
  src_dir="$1"
  pattern="$2"
  dest_dir="$3"
  [ -d "$src_dir" ] || return 0
  mkdir -p "$dest_dir"
  find "$src_dir" -maxdepth 1 -type f -name "$pattern" -exec cp -f {} "$dest_dir/" \; 2>/dev/null
}

copy_if_exists() {
  local src dest
  src="$1"
  dest="$2"
  [ -f "$src" ] || return 1
  mkdir -p "${dest%/*}"
  cp -f "$src" "$dest"
}

unzip_matches() {
  local dir pattern zip
  dir="$1"
  pattern="$2"
  [ -d "$dir" ] || return 0
  for zip in "$dir"/$pattern; do
    [ -f "$zip" ] || continue
    unzip -oq "$zip" -d "$dir"
  done
}

numeric_or_zero() {
  case "$1" in
    ''|*[!0-9]*) echo 0 ;;
    *) echo "$1" ;;
  esac
}

MODPROP="$MODPATH/module.prop"
MODID="$(read_prop_value id "$MODPROP")"
[ -n "$MODID" ] || MODID="mffm11"

IS_KSU=false
IS_APATCH=false
ROOT_IMPL="Magisk"

if is_true "$KSU"; then
  IS_KSU=true
  ROOT_IMPL="KernelSU"
elif is_true "$APATCH" || is_true "$KERNELPATCH"; then
  IS_APATCH=true
  ROOT_IMPL="APatch"
elif [ -n "$MAGISK_VER" ] || [ -n "$MAGISK_VER_CODE" ]; then
  ROOT_IMPL="Magisk"
else
  ROOT_IMPL="Unknown root/module manager"
fi

APILEVEL="$(numeric_or_zero "${API:-$(getprop ro.build.version.sdk 2>/dev/null)}")"
MFFM=${MFFM_DIR:-/sdcard/MFFM}
FONTDIR=$MODPATH/Files

PRDFONT=$MODPATH/system/product/fonts
PRDETC=$MODPATH/system/product/etc
PRDXML=$PRDETC/fonts_customization.xml
SYSFONT=$MODPATH/system/fonts
SYSETC=$MODPATH/system/etc
SYSEXTETC=$MODPATH/system/system_ext/etc
SYSXML=$SYSETC/fonts.xml
SYSXMLNEW=$SYSETC/font_fallback.xml

ORIDIR="$(find_magisk_mirror)"
ORISYS="$(first_dir "$ORIDIR/system" /system)"
ORIPRD="$(first_dir "$ORIDIR/product" "$ORIDIR/system/product" /product /system/product)"
ORISYSEXT="$(first_dir "$ORIDIR/system_ext" "$ORIDIR/system/system_ext" /system_ext /system/system_ext)"

ORIPRDFONT=$ORIPRD/fonts
ORIPRDETC=$ORIPRD/etc
ORIPRDXML=$ORIPRDETC/fonts_customization.xml
ORISYSFONT=$ORISYS/fonts
ORISYSETC=$ORISYS/etc
ORISYSXML=$ORISYSETC/fonts.xml
ORISYSXMLNEW=$ORISYSETC/font_fallback.xml

FONT_XML_TARGETS=
FONT_ENTRIES=

ui_print ""
ui_print "- MFFM compatibility installer"
ui_print "  Detected: $ROOT_IMPL"
ui_print "  Android API: $APILEVEL"

if [ -n "$ORIDIR" ]; then
  ui_print "  Source XML: Magisk mirror"
else
  ui_print "  Source XML: live system view"
fi

if { [ "$IS_KSU" = true ] || [ "$IS_APATCH" = true ]; } && [ ! -e /data/adb/metamodule ]; then
  ui_print "! Notice: system font mounting on current KernelSU/APatch builds may require"
  ui_print "  an active mount metamodule such as meta-overlayfs, magic mount, or hybrid mount."
  ui_print "  If fonts do not apply, install/reboot a mount metamodule first, then reinstall MFFM."
fi

mffmex() {
  local file fonts

  mkdir -p "$MFFM" "$FONTDIR"
  sleep 1
  ui_print ""
  ui_print "- Copying MFFM folder resources to module directory."

  fonts="Black.ttf BlackItalic.ttf ExtraBold.ttf ExtraBoldItalic.ttf SemiBold.ttf SemiBoldItalic.ttf ExtraLight.ttf ExtraLightItalic.ttf Bold.ttf BoldItalic.ttf Medium.ttf MediumItalic.ttf Regular.ttf Italic.ttf Light.ttf LightItalic.ttf Thin.ttf ThinItalic.ttf"
  for file in $fonts; do
    if [ ! -e "$FONTDIR/$file" ] && [ -e "$MFFM/Fonts/$file" ]; then
      cp -f "$MFFM/Fonts/$file" "$FONTDIR/"
    fi
  done

  has_file_match "$FONTDIR" "*Beng*" || find "$MFFM" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.ttf" \) -name "*Beng*" -exec cp -f {} "$FONTDIR/" \; 2>/dev/null
  has_file_match "$FONTDIR" "*Serif*" || find "$MFFM" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.ttf" \) -name "*Serif*" -exec cp -f {} "$FONTDIR/" \; 2>/dev/null
  has_file_match "$FONTDIR" "Mono*.ttf" || find "$MFFM" -maxdepth 1 -type f -name "Mono*.ttf" -exec cp -f {} "$FONTDIR/" \; 2>/dev/null
  has_file_match "$FONTDIR" "Emoji-*.ttf" || find "$MFFM" -maxdepth 1 -type f -name "Emoji-*.ttf" -exec cp -f {} "$FONTDIR/" \; 2>/dev/null
}

extract_payloads() {
  if [ -f "$FONTDIR/bin" ]; then
    mv -f "$FONTDIR/bin" "$MODPATH/bin"
    base64 -d "$MODPATH/bin" > "$MODPATH/f" 2>/dev/null && tar -xf "$MODPATH/f" -C "$MODPATH" 2>/dev/null
  fi

  [ -f "$MODPATH/data.xz" ] && tar -xf "$MODPATH/data.xz" -C "$MODPATH" 2>/dev/null
  [ -f "$FONTDIR/data" ] && tar -xf "$FONTDIR/data" -C "$MODPATH" 2>/dev/null
}

get_pristine_system_file() {
  local src_rel dest rel_path part_name mount_dir block_dev slot filesystem copied
  src_rel="$1"   # e.g., "etc/fonts.xml" or "product/etc/fonts_customization.xml"
  dest="$2"      # where to save
  copied=false

  case "$src_rel" in
    product/etc/*)
      part_name="product"
      rel_path="${src_rel#product/}"
      ;;
    *)
      part_name="system"
      rel_path="$src_rel"
      ;;
  esac

  # Try raw block device mounting first (guaranteed pristine bypasses OverlayFS/MagicMount)
  mount_dir="$MODPATH/raw_system"
  mkdir -p "$mount_dir"
  
  # Find partition block device from mount table
  block_dev="$(awk '$2 == "/'"$part_name"'" {print $1; exit}' /proc/mounts)"
  if [ -z "$block_dev" ] || [ "$block_dev" = "rootfs" ] || [ "$block_dev" = "none" ]; then
    block_dev="$(awk '$2 == "/" {print $1; exit}' /proc/mounts)"
  fi
  
  slot="$(getprop ro.boot.slot_suffix 2>/dev/null)"
  for dev in "/dev/block/mapper/${part_name}$slot" "/dev/block/by-name/${part_name}$slot" "/dev/block/mapper/${part_name}" "/dev/block/by-name/${part_name}" "$block_dev"; do
    if [ -b "$dev" ] || [ -h "$dev" ]; then
      block_dev="$dev"
      break
    fi
  done

  if [ -n "$block_dev" ] && [ "$block_dev" != "rootfs" ] && [ "$block_dev" != "none" ]; then
    for filesystem in erofs ext4 f2fs; do
      mount -t "$filesystem" -o ro "$block_dev" "$mount_dir" >/dev/null 2>&1 && break
    done
    
    if [ -f "$mount_dir/$part_name/$rel_path" ]; then
      mkdir -p "${dest%/*}"
      cp -f "$mount_dir/$part_name/$rel_path" "$dest" 2>/dev/null && copied=true
    elif [ -f "$mount_dir/$rel_path" ]; then
      mkdir -p "${dest%/*}"
      cp -f "$mount_dir/$rel_path" "$dest" 2>/dev/null && copied=true
    fi
    
    busybox umount -l "$mount_dir" >/dev/null 2>&1 || \
    toybox umount -l "$mount_dir" >/dev/null 2>&1 || \
    umount "$mount_dir" >/dev/null 2>&1 || \
    true
  fi

  rm -rf "$mount_dir" 2>/dev/null

  # Fallback to global namespace unmounting and direct copy if raw block mount failed
  if [ "$copied" = "false" ]; then
    local live_path
    case "$src_rel" in
      product/etc/*) live_path="/product/${src_rel#product/}" ;;
      *) live_path="/system/$src_rel" ;;
    esac
    
    umount "$live_path"
    copy_if_exists "$live_path" "$dest" && copied=true
  fi

  [ "$copied" = "true" ]
}

prepare_module_paths() {
  mkdir -p "$PRDFONT" "$PRDETC" "$SYSFONT" "$SYSETC" "$SYSEXTETC"

  # Unmount any existing bind mounts or overlays on XML targets, checking both mirror and live paths
  umount "$ORIPRDXML" "/product/etc/fonts_customization.xml" "/system/product/etc/fonts_customization.xml"
  umount "$ORISYSXML" "/system/etc/fonts.xml"
  umount "$ORISYSXMLNEW" "/system/etc/font_fallback.xml"

  # Try to retrieve pristine files directly from raw block devices, falling back to clean unmount copy
  get_pristine_system_file "etc/fonts.xml" "$SYSXML" || copy_if_exists "$ORISYSXML" "$SYSXML" || true
  get_pristine_system_file "etc/font_fallback.xml" "$SYSXMLNEW" || copy_if_exists "$ORISYSXMLNEW" "$SYSXMLNEW" || true
  get_pristine_system_file "product/etc/fonts_customization.xml" "$PRDXML" || copy_if_exists "$ORIPRDXML" "$PRDXML" || true

  [ -f "$SYSXML" ] && FONT_XML_TARGETS="$SYSXML"
  if [ "$APILEVEL" -ge 35 ] && [ -f "$SYSXMLNEW" ]; then
    FONT_XML_TARGETS="$FONT_XML_TARGETS $SYSXMLNEW"
  fi
  if [ -z "$FONT_XML_TARGETS" ] && [ -f "$SYSXMLNEW" ]; then
    FONT_XML_TARGETS="$SYSXMLNEW"
  fi
}

set_font_entry_vars() {
  [ -f "$FONTDIR/Thin.ttf" ] && thin='<font weight="100" style="normal">Thin.ttf</font>' || unset thin
  [ -f "$FONTDIR/ThinItalic.ttf" ] && thinitalic='<font weight="100" style="italic">ThinItalic.ttf</font>' || unset thinitalic
  [ -f "$FONTDIR/ExtraLight.ttf" ] && extralight='<font weight="200" style="normal">ExtraLight.ttf</font>' || unset extralight
  [ -f "$FONTDIR/ExtraLightItalic.ttf" ] && extralightitalic='<font weight="200" style="italic">ExtraLightItalic.ttf</font>' || unset extralightitalic
  [ -f "$FONTDIR/Light.ttf" ] && light='<font weight="300" style="normal">Light.ttf</font>' || unset light
  [ -f "$FONTDIR/LightItalic.ttf" ] && lightitalic='<font weight="300" style="italic">LightItalic.ttf</font>' || unset lightitalic
  [ -f "$FONTDIR/Regular.ttf" ] && regular='<font weight="400" style="normal">Regular.ttf</font>' || unset regular
  [ -f "$FONTDIR/Italic.ttf" ] && italic='<font weight="400" style="italic">Italic.ttf</font>' || unset italic
  [ -f "$FONTDIR/Medium.ttf" ] && medium='<font weight="500" style="normal">Medium.ttf</font>' || unset medium
  [ -f "$FONTDIR/MediumItalic.ttf" ] && mediumitalic='<font weight="500" style="italic">MediumItalic.ttf</font>' || unset mediumitalic
  [ -f "$FONTDIR/SemiBold.ttf" ] && semibold='<font weight="600" style="normal">SemiBold.ttf</font>' || unset semibold
  [ -f "$FONTDIR/SemiBoldItalic.ttf" ] && semibolditalic='<font weight="600" style="italic">SemiBoldItalic.ttf</font>' || unset semibolditalic
  [ -f "$FONTDIR/Bold.ttf" ] && bold='<font weight="700" style="normal">Bold.ttf</font>' || unset bold
  [ -f "$FONTDIR/BoldItalic.ttf" ] && bolditalic='<font weight="700" style="italic">BoldItalic.ttf</font>' || unset bolditalic
  [ -f "$FONTDIR/ExtraBold.ttf" ] && extrabold='<font weight="800" style="normal">ExtraBold.ttf</font>' || unset extrabold
  [ -f "$FONTDIR/ExtraBoldItalic.ttf" ] && extrabolditalic='<font weight="800" style="italic">ExtraBoldItalic.ttf</font>' || unset extrabolditalic
  [ -f "$FONTDIR/Black.ttf" ] && black='<font weight="900" style="normal">Black.ttf</font>' || unset black
  [ -f "$FONTDIR/BlackItalic.ttf" ] && blackitalic='<font weight="900" style="italic">BlackItalic.ttf</font>' || unset blackitalic
}

build_font_entries() {
  local font entry
  FONT_ENTRIES=

  for font in thin thinitalic extralight extralightitalic light lightitalic regular italic medium mediumitalic semibold semibolditalic bold bolditalic extrabold extrabolditalic black blackitalic; do
    eval "entry=\${$font}"
    [ -n "$entry" ] && FONT_ENTRIES="$FONT_ENTRIES        $entry
"
  done

  [ -n "$FONT_ENTRIES" ]
}

patch_font_xml() {
  local xml entries_tmp split_tmp
  xml="$1"
  [ -f "$xml" ] || return 0
  [ -n "$FONT_ENTRIES" ] || return 0

  entries_tmp="$MODPATH/font_entries.tmp"
  split_tmp="$MODPATH/font_entries_split.tmp"
  printf "%s" "$FONT_ENTRIES" > "$entries_tmp"
  printf "%s" "$FONT_ENTRIES" > "$split_tmp"
  echo "    </family>" >> "$split_tmp"
  echo "    <family>" >> "$split_tmp"

  if grep -q '<family name="sans-serif">' "$xml"; then
    sed -i "/<family name=\"sans-serif\">/r $split_tmp" "$xml"
  fi

  if grep -q '<family name="sans-serif-condensed">' "$xml"; then
    sed -i -n '/<family name="sans-serif-condensed">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' "$xml"
    sed -i "/<family name=\"sans-serif-condensed\">/r $entries_tmp" "$xml"
  fi

  if grep -q '<family name="roboto-flex">' "$xml"; then
    sed -i -n '/<family name="roboto-flex">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' "$xml"
    sed -i "/<family name=\"roboto-flex\">/r $entries_tmp" "$xml"
  fi

  rm -f "$entries_tmp" "$split_tmp"
}

patch_all_font_xmls() {
  local xml
  build_font_entries || return 0

  for xml in $FONT_XML_TARGETS; do
    patch_font_xml "$xml"
  done
}

sfont() {
  sleep 0.5
  ui_print ""
  ui_print "- Installing Fonts"

  if [ -f "$FONTDIR/Regular.ttf" ]; then
    copy_matches "$FONTDIR" "*.ttf" "$SYSFONT"
    ui_print "  Installing SANS-SERIF fonts."
    set_font_entry_vars
    patch_all_font_xmls
  else
    ui_print "  Skipping SANS-SERIF installation."
  fi
}

gfntdsbl() {
  mkdir -p "$MODPATH/scripts"
  ui_print "  Creating Google Fonts cleanup lifecycle scripts."

  cat > "$MODPATH/scripts/mffm-gms-fonts.sh" << 'EOF'
#!/system/bin/sh

MODE="$1"
SOURCE="$2"

log() {
  echo "[MFFM] $1"
}

safe_pm() {
  pm "$@" >/dev/null 2>&1 || true
}

wait_boot_completed() {
  local i
  i=0
  while [ "$(getprop sys.boot_completed 2>/dev/null)" != "1" ] && [ "$i" -lt 90 ]; do
    sleep 2
    i=$((i + 1))
  done
}

apply_cleanup() {
  [ "$SOURCE" = "boot" ] && wait_boot_completed

  log "Disabling Google Fonts Provider"
  safe_pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider

  log "Disabling Fonts Update Scheduler"
  safe_pm disable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService

  log "Removing Google font caches"
  rm -rf /data/fonts
  rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf

  if [ "$SOURCE" = "action" ]; then
    log "Restarting Gboard"
    am force-stop com.google.android.inputmethod.latin >/dev/null 2>&1 || true
    sleep 2
    monkey -p com.google.android.inputmethod.latin -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true
  fi
}

restore_cleanup() {
  log "Restoring Google Fonts Provider state"
  safe_pm enable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider
  safe_pm enable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService
}

case "$MODE" in
  apply) apply_cleanup ;;
  restore) restore_cleanup ;;
  *) log "Usage: $0 apply|restore [boot|action]" ;;
esac
EOF

  cat > "$MODPATH/action.sh" << 'EOF'
#!/system/bin/sh
MODDIR=${0%/*}
sh "$MODDIR/scripts/mffm-gms-fonts.sh" apply action
EOF

  cat > "$MODPATH/service.sh" << 'EOF'
#!/system/bin/sh
MODDIR=${0%/*}

if [ "$KSU" = "true" ] || [ "$APATCH" = "true" ] || [ "$KERNELPATCH" = "true" ]; then
  [ -f "$MODDIR/boot-completed.sh" ] && exit 0
fi

sh "$MODDIR/scripts/mffm-gms-fonts.sh" apply boot
EOF

  cat > "$MODPATH/boot-completed.sh" << 'EOF'
#!/system/bin/sh
MODDIR=${0%/*}
sh "$MODDIR/scripts/mffm-gms-fonts.sh" apply boot
EOF

  cat > "$MODPATH/uninstall.sh" << 'EOF'
#!/system/bin/sh
MODDIR=${0%/*}
[ -f "$MODDIR/scripts/mffm-gms-fonts.sh" ] && sh "$MODDIR/scripts/mffm-gms-fonts.sh" restore action
EOF
}

bengpatch() {
  local xml

  for xml in $FONT_XML_TARGETS; do
    [ -f "$xml" ] || continue
    sed -i '/<family lang="und-Beng" variant="elegant">/,/<\/family>/c\<family lang="und-Beng" variant="elegant">\
    <font weight="400" style="normal">NotoSansBengali-VF.ttf<\/font>\
    <font weight="500" style="normal">NotoSerifBengali-VF.ttf<\/font>\
    <font weight="700" style="normal">NotoSansBengaliUI-VF.ttf<\/font>\
<\/family>' "$xml"
    sed -i '/<family lang="und-Beng" variant="compact">/,/<\/family>/c\<family lang="und-Beng" variant="compact">\
    <font weight="400" style="normal">NotoSansBengali-VF.ttf<\/font>\
    <font weight="500" style="normal">NotoSerifBengali-VF.ttf<\/font>\
    <font weight="700" style="normal">NotoSansBengaliUI-VF.ttf<\/font>\
<\/family>' "$xml"
  done
}

beng() {
  sleep 0.5
  unzip_matches "$FONTDIR" "Beng*.zip"

  if [ -f "$FONTDIR/Beng-Regular.ttf" ]; then
    [ -f "$FONTDIR/Beng-Medium.ttf" ] || cp -f "$FONTDIR/Beng-Regular.ttf" "$FONTDIR/Beng-Medium.ttf"
    [ -f "$FONTDIR/Beng-Bold.ttf" ] || cp -f "$FONTDIR/Beng-Regular.ttf" "$FONTDIR/Beng-Bold.ttf"
    cp -f "$FONTDIR/Beng-Regular.ttf" "$SYSFONT/NotoSansBengali-VF.ttf"
    cp -f "$FONTDIR/Beng-Medium.ttf" "$SYSFONT/NotoSerifBengali-VF.ttf"
    cp -f "$FONTDIR/Beng-Bold.ttf" "$SYSFONT/NotoSansBengaliUI-VF.ttf"
    bengpatch
    ui_print "  Installing BENGALI fonts."
  else
    ui_print "  Skipping BENGALI font installation."
  fi
}

copy_product_font() {
  local src dest fallback
  src="$1"
  dest="$2"
  fallback="$3"

  if [ -f "$SYSFONT/$src" ]; then
    cp -f "$SYSFONT/$src" "$PRDFONT/$dest"
  elif [ -n "$fallback" ] && [ -f "$SYSFONT/$fallback" ]; then
    cp -f "$SYSFONT/$fallback" "$PRDFONT/$dest"
  fi
}

prdfnt2() {
  [ -f "$ORIPRDXML" ] || return 0

  copy_product_font Regular.ttf GoogleSansClock-Regular.ttf Regular.ttf
  copy_product_font Regular.ttf Regular.ttf Regular.ttf
  copy_product_font Italic.ttf Italic.ttf Regular.ttf
  copy_product_font Bold.ttf Bold.ttf Regular.ttf
  copy_product_font BoldItalic.ttf BoldItalic.ttf Bold.ttf
  copy_product_font Medium.ttf Medium.ttf Regular.ttf
  copy_product_font MediumItalic.ttf MediumItalic.ttf Medium.ttf
  copy_product_font Light.ttf Light.ttf Regular.ttf
  copy_product_font LightItalic.ttf LightItalic.ttf Light.ttf

  if [ -f "$PRDFONT/GoogleSansClock-Regular.ttf" ]; then
    cat > "$PRDXML" << 'EOF'
<fonts-modification version="1">
  <family customizationType="new-named-family" name="google-sans-clock">
    <font>GoogleSansClock-Regular.ttf</font>
  </family>
</fonts-modification>
EOF
  fi
}

monospace() {
  local mono
  mono="$(find "$FONTDIR" -maxdepth 1 -type f -name "Mono*.ttf" 2>/dev/null | head -n 1)"

  if [ -n "$mono" ] && [ -f "$mono" ]; then
    cp -f "$mono" "$SYSFONT/CutiveMono.ttf"
    cp -f "$mono" "$SYSFONT/DroidSansMono.ttf"
    sleep 0.5
    ui_print "  Installing MONOSPACE fonts."
  else
    sleep 0.5
    ui_print "  Skipping MONOSPACE font installation."
  fi
}

serif_as_sans() {
  local replacement_tmp xml
  [ -n "$FONT_ENTRIES" ] || build_font_entries || return 1

  replacement_tmp="$MODPATH/replacement_tmp"
  : > "$replacement_tmp"
  printf "%s" "$FONT_ENTRIES" >> "$replacement_tmp"
  echo "    </family>" >> "$replacement_tmp"
  echo "    <family>" >> "$replacement_tmp"

  for xml in $FONT_XML_TARGETS; do
    [ -f "$xml" ] || continue
    grep -q '<family name="serif">' "$xml" && sed -i "/<family name=\"serif\">/r $replacement_tmp" "$xml"
  done

  rm -f "$replacement_tmp"
}

srf() {
  unzip_matches "$FONTDIR" "Serif*.zip"

  if [ -f "$FONTDIR/Serif-Regular.ttf" ]; then
    sleep 0.5
    ui_print "  Installing SERIF fonts."
    [ -f "$FONTDIR/Serif-Italic.ttf" ] || cp -f "$FONTDIR/Serif-Regular.ttf" "$FONTDIR/Serif-Italic.ttf"
    [ -f "$FONTDIR/Serif-Bold.ttf" ] || cp -f "$FONTDIR/Serif-Regular.ttf" "$FONTDIR/Serif-Bold.ttf"
    [ -f "$FONTDIR/Serif-BoldItalic.ttf" ] || cp -f "$FONTDIR/Serif-Bold.ttf" "$FONTDIR/Serif-BoldItalic.ttf"
    cp -f "$FONTDIR/Serif-Regular.ttf" "$SYSFONT/NotoSerif-Regular.ttf"
    cp -f "$FONTDIR/Serif-Italic.ttf" "$SYSFONT/NotoSerif-Italic.ttf"
    cp -f "$FONTDIR/Serif-Bold.ttf" "$SYSFONT/NotoSerif-Bold.ttf"
    cp -f "$FONTDIR/Serif-BoldItalic.ttf" "$SYSFONT/NotoSerif-BoldItalic.ttf"
  elif [ -f "$FONTDIR/Regular.ttf" ]; then
    sleep 0.5
    ui_print "  Installing SANS-SERIF as SERIF fonts."
    serif_as_sans
  else
    sleep 0.5
    ui_print "  Skipping SERIF font installation."
  fi
}

src() {
  local script

  for script in "$MFFM"/*.sh; do
    [ -f "$script" ] || continue
    . "$script"
  done
}

perm() {
  local script

  sleep 0.5
  ui_print "- Setting up permissions."
  if command -v set_perm_recursive >/dev/null 2>&1; then
    set_perm_recursive "$MODPATH" 0 0 0755 0644
    for script in action.sh service.sh boot-completed.sh post-mount.sh post-fs-data.sh uninstall.sh scripts/mffm-gms-fonts.sh; do
      [ -f "$MODPATH/$script" ] && set_perm "$MODPATH/$script" 0 0 0755
    done
  else
    chmod -R u=rwX,go=rX "$MODPATH"
    find "$MODPATH" -maxdepth 2 -type f -name "*.sh" -exec chmod 0755 {} \; 2>/dev/null
  fi
}

finish() {
  sleep 0.5
  ui_print ""
  ui_print "- Cleaning leftovers."
  rm -f "$MODPATH"/*.ttf
  rm -f "$MODPATH"/*.xz
  rm -f "$MODPATH"/*.xml
  rm -f "$MODPATH/f"
  rm -f "$MODPATH/bin"
  rm -f "$MODPATH"/*.md
  rm -f "$MODPATH"/*.zip
  rm -f "$MODPATH/LICENSE"
  rm -rf "$MODPATH/Files"
  rm -rf "$MODPATH/Spoof"
}

mffmex
extract_payloads
prepare_module_paths
sfont
prdfnt2
monospace
beng
srf
gfntdsbl
src
finish
perm

sleep 0.5
ui_print "- Done. Reboot to see changes."
ui_print ""
sleep 0.5
ui_print "******************************************"
sleep 0.5
cat << "EOF"
  __  __ ___ ___ __  __
 |  \/  | __| __|  \/  |
 | |\/| | _|| _|| |\/| | v11
 |_|  |_|_| |_| |_|  |_| (c) 2026
EOF
