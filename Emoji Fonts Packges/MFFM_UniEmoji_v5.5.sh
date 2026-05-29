#!/system/bin/sh
#
# Universal Emoji Extension for MFFM.
# Runtime model adapted for this template from:
# https://github.com/mistu01/MFFMEmoji

ue_ui() {
  if command -v ui_print >/dev/null 2>&1; then
    ui_print "$1"
  else
    echo "$1"
  fi
}

ue_first_emoji_font() {
  local dir match

  for dir in "${FONTDIR:-}" "${MFFM:-/sdcard/MFFM}" "$MODPATH"; do
    [ -n "$dir" ] && [ -d "$dir" ] || continue
    match="$(find "$dir" -maxdepth 1 -type f \( -name 'Emoji*.ttf' -o -name 'emoji*.ttf' -o -name 'EMOJI*.ttf' \) 2>/dev/null | head -n 1)"
    [ -n "$match" ] && {
      echo "$match"
      return 0
    }
  done

  [ -f "${SYSFONT:-$MODPATH/system/fonts}/NotoColorEmoji.ttf" ] && {
    echo "${SYSFONT:-$MODPATH/system/fonts}/NotoColorEmoji.ttf"
    return 0
  }

  return 1
}

ue_append_hook() {
  local file marker mode trigger background
  file="$1"
  marker="$2"
  mode="$3"
  trigger="$4"
  background="${5:-}"

  [ -f "$file" ] || {
    mkdir -p "${file%/*}"
    cat > "$file" << 'EOF'
#!/system/bin/sh
MODDIR=${0%/*}
EOF
  }

  grep -q "$marker" "$file" 2>/dev/null && return 0

  if [ "$background" = "background" ]; then
    cat >> "$file" << EOF

# $marker
[ -f "\$MODDIR/scripts/mffm-uniemoji.sh" ] && sh "\$MODDIR/scripts/mffm-uniemoji.sh" "$mode" "$trigger" &
# End $marker
EOF
  else
    cat >> "$file" << EOF

# $marker
[ -f "\$MODDIR/scripts/mffm-uniemoji.sh" ] && sh "\$MODDIR/scripts/mffm-uniemoji.sh" "$mode" "$trigger"
# End $marker
EOF
  fi
}

ue_write_runtime_helper() {
  mkdir -p "$MODPATH/scripts"

  cat > "$MODPATH/scripts/mffm-uniemoji.sh" << 'UNIEMOJI_HELPER'
#!/system/bin/sh

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

SCRIPT_DIR=${0%/*}
case "$SCRIPT_DIR" in
  */scripts) MODPATH=${MODPATH:-${SCRIPT_DIR%/scripts}} ;;
  *) MODPATH=${MODPATH:-$SCRIPT_DIR} ;;
esac

MODE_ARG="${1:-runtime}"
TRIGGER_REASON="${2:-manual}"
MFFM_DIR="${MFFM:-/sdcard/MFFM}"
FONTDIR="${FONTDIR:-$MODPATH/Files}"
FONT_NAME="NotoColorEmoji.ttf"
FONT_DIR="$MODPATH/system/fonts"
FONT_PATH="$FONT_DIR/$FONT_NAME"
SOURCE_FONT="$MODPATH/Emoji.ttf"
MODULE_ID="$(sed -n 's/^id=//p' "$MODPATH/module.prop" 2>/dev/null | head -n 1)"
[ -n "$MODULE_ID" ] || MODULE_ID="$(basename "$MODPATH")"

STATE_DIR="$MODPATH/var/uniemoji"
PUBLIC_LOG_DIR="$MFFM_DIR/EmojiModule"
PUBLIC_LOG_FILE="$PUBLIC_LOG_DIR/service.log"
PUBLIC_STATUS_FILE="$PUBLIC_LOG_DIR/last-status.txt"
PUBLIC_README_FILE="$PUBLIC_LOG_DIR/README.txt"
PERSISTENT_STATE_DIR="/data/adb/mffm-uniemoji-state/$MODULE_ID"
DATA_FONT_BACKUP_DIR="$PERSISTENT_STATE_DIR/data-font-backups"
DATA_FONT_BACKUP_MANIFEST="$PERSISTENT_STATE_DIR/data-font-backups.list"
DATA_FONT_PATHS_FILE="$STATE_DIR/data-font-paths.list"
TOUCHED_PACKAGES_FILE="$STATE_DIR/touched-packages.list"
RUN_DATA_FONT_PATHS_FILE="$STATE_DIR/data-font-paths.run"
RUN_TOUCHED_PACKAGES_FILE="$STATE_DIR/touched-packages.run"
PACKAGE_SNAPSHOT_FILE="$STATE_DIR/packages.snapshot"
PACKAGE_SNAPSHOT_CURRENT_FILE="$STATE_DIR/packages.snapshot.current"
LOCKDIR="$STATE_DIR/run.lock"
SCHEDULER_LOCKDIR="$STATE_DIR/scheduler.lock"
UNINSTALLING_FLAG="$STATE_DIR/uninstalling"

PROTECTED_INSTALLER_PACKAGES="
com.topjohnwu.magisk
io.github.vvb2060.magisk
me.weishu.kernelsu
me.bmax.apatch
"

append_log() {
  mkdir -p "$STATE_DIR" 2>/dev/null
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$STATE_DIR/service.log"
  ensure_public_paths
  [ -d "$PUBLIC_LOG_DIR" ] && echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$PUBLIC_LOG_FILE"
}

ui_note() {
  if command -v ui_print >/dev/null 2>&1; then
    ui_print "$1"
  else
    echo "$1"
  fi
}

ensure_public_paths() {
  mkdir -p "$PUBLIC_LOG_DIR" 2>/dev/null
  [ -d "$PUBLIC_LOG_DIR" ] || return 0
  cat > "$PUBLIC_README_FILE" << 'EOF'
MFFM UniEmoji runtime files
- service.log: runtime repair log
- last-status.txt: latest status summary
EOF
}

update_public_status() {
  ensure_public_paths
  [ -d "$PUBLIC_LOG_DIR" ] && printf '%s\n' "$1" > "$PUBLIC_STATUS_FILE"
}

append_unique_line() {
  local target_file value target_dir
  target_file="$1"
  value="$2"
  [ -n "$target_file" ] && [ -n "$value" ] || return 0
  target_dir="${target_file%/*}"
  [ "$target_dir" != "$target_file" ] && mkdir -p "$target_dir" 2>/dev/null
  touch "$target_file" 2>/dev/null || return 0
  grep -Fxq "$value" "$target_file" 2>/dev/null && return 0
  printf '%s\n' "$value" >> "$target_file"
}

path_checksum() {
  local checksum
  checksum="$(printf '%s' "$1" | cksum)"
  echo "${checksum%% *}"
}

file_checksum() {
  local checksum
  [ -f "$1" ] || return 1
  checksum="$(cksum "$1" 2>/dev/null)" || return 1
  echo "${checksum%% *}"
}

files_are_same() {
  local first_sum second_sum
  [ -f "$1" ] && [ -f "$2" ] || return 1
  if command -v cmp >/dev/null 2>&1; then
    cmp -s "$1" "$2"
    return $?
  fi
  first_sum="$(file_checksum "$1")" || return 1
  second_sum="$(file_checksum "$2")" || return 1
  [ "$first_sum" = "$second_sum" ]
}

detect_root_solution() {
  if [ "$KSU" = "true" ] || [ -d /data/adb/ksu ]; then
    echo "KernelSU"
  elif [ "$APATCH" = "true" ] || [ "$KERNELPATCH" = "true" ] || [ -d /data/adb/ap ]; then
    echo "APatch"
  elif [ -n "$MAGISK_VER_CODE" ] || [ -f /data/adb/magisk/util_functions.sh ]; then
    echo "Magisk"
  else
    echo "Unknown"
  fi
}

metamodule_present() {
  [ -e /data/adb/metamodule ] && return 0
  grep -Rqs '^metamodule=\(1\|true\)$' /data/adb/modules/*/module.prop 2>/dev/null && return 0
  grep -Rqs '^metamodule=\(1\|true\)$' /data/adb/modules_update/*/module.prop 2>/dev/null && return 0
  return 1
}

determine_mount_mode() {
  ROOT_SOLUTION="$(detect_root_solution)"
  MOUNT_MODE="full"
  case "$ROOT_SOLUTION" in
    KernelSU|APatch)
      if ! metamodule_present; then
        MOUNT_MODE="data-only"
      fi
      ;;
  esac
}

first_source_font() {
  local dir match

  [ -f "$FONT_PATH" ] && {
    echo "$FONT_PATH"
    return 0
  }
  [ -f "$SOURCE_FONT" ] && {
    echo "$SOURCE_FONT"
    return 0
  }

  for dir in "$FONTDIR" "$MFFM_DIR" "$MODPATH"; do
    [ -d "$dir" ] || continue
    match="$(find "$dir" -maxdepth 1 -type f \( -name 'Emoji*.ttf' -o -name 'emoji*.ttf' -o -name 'EMOJI*.ttf' \) 2>/dev/null | head -n 1)"
    [ -n "$match" ] && {
      echo "$match"
      return 0
    }
  done

  return 1
}

ensure_font_payload() {
  local source_font
  mkdir -p "$FONT_DIR" 2>/dev/null

  [ -f "$FONT_PATH" ] && return 0

  source_font="$(first_source_font)" || {
    append_log "WARN: Missing Emoji*.ttf payload"
    return 1
  }

  cp -f "$source_font" "$FONT_PATH" 2>/dev/null || {
    append_log "WARN: Failed to stage emoji font from $source_font"
    return 1
  }
  chmod 0644 "$FONT_PATH" 2>/dev/null
  append_log "INFO: Staged emoji font from $source_font"
  return 0
}

system_scan_dirs() {
  local dir
  for dir in "$ORISYSFONT" "$ORIPRDFONT" "${ORISYSEXT:+$ORISYSEXT/fonts}" /system/fonts /system/product/fonts /product/fonts /system/system_ext/fonts /system_ext/fonts /vendor/fonts; do
    [ -n "$dir" ] && [ -d "$dir" ] && printf '%s\n' "$dir"
  done
}

find_emoji_font_candidates() {
  local search_root
  search_root="$1"
  [ -d "$search_root" ] || return 0
  find "$search_root" -type f \( -name '*Emoji*.ttf' -o -name '*emoji*.ttf' -o -name '*EMOJI*.ttf' \) 2>/dev/null
}

module_font_target_for() {
  local source_path base_name
  source_path="$1"
  base_name="$(basename "$source_path")"

  case "$source_path" in
    */system/fonts/*) echo "$MODPATH/system/fonts/$base_name" ;;
    */product/fonts/*|*/system/product/fonts/*) echo "$MODPATH/system/product/fonts/$base_name" ;;
    */system_ext/fonts/*|*/system/system_ext/fonts/*) echo "$MODPATH/system/system_ext/fonts/$base_name" ;;
    */vendor/fonts/*|*/system/vendor/fonts/*) echo "$MODPATH/system/vendor/fonts/$base_name" ;;
    *) return 1 ;;
  esac
}

replace_system_emoji_fonts() {
  local dir candidate_file source_path target_path replaced failed
  replaced=0
  failed=0

  [ "$MOUNT_MODE" = "full" ] || {
    ui_note "- UniEmoji: system scan skipped in data-only mode"
    append_log "INFO: System emoji scan skipped in data-only mode"
    return 0
  }

  ensure_font_payload || return 0

  candidate_file="$STATE_DIR/system-font-candidates.$$"
  : > "$candidate_file"
  system_scan_dirs | while IFS= read -r dir; do
    find_emoji_font_candidates "$dir"
  done > "$candidate_file"

  while IFS= read -r source_path; do
    [ -n "$source_path" ] || continue
    target_path="$(module_font_target_for "$source_path")" || continue
    mkdir -p "${target_path%/*}" 2>/dev/null

    if [ "$target_path" = "$FONT_PATH" ]; then
      replaced=$((replaced + 1))
      ui_note "- UniEmoji: replaced system font $(basename "$source_path")"
      append_log "INFO: Replaced system emoji font with primary payload: $source_path"
      continue
    fi

    if cp -f "$FONT_PATH" "$target_path" 2>/dev/null; then
      chmod 0644 "$target_path" 2>/dev/null
      replaced=$((replaced + 1))
      ui_note "- UniEmoji: replaced system font $(basename "$source_path")"
      append_log "INFO: Replaced system emoji font: $source_path"
    else
      failed=$((failed + 1))
      append_log "WARN: Failed system emoji replacement: $source_path"
    fi
  done < "$candidate_file"

  rm -f "$candidate_file" 2>/dev/null
  append_log "INFO: System scan summary: replaced=$replaced failed=$failed"
}

data_font_backup_path_for() {
  local checksum base_name
  checksum="$(path_checksum "$1")"
  base_name="$(basename "$1")"
  echo "$DATA_FONT_BACKUP_DIR/${checksum}-${base_name}"
}

capture_file_metadata() {
  local target_path meta_path uid gid mode context
  target_path="$1"
  meta_path="$2"
  uid="$(stat -c '%u' "$target_path" 2>/dev/null)"
  gid="$(stat -c '%g' "$target_path" 2>/dev/null)"
  mode="$(stat -c '%a' "$target_path" 2>/dev/null)"
  context="$(stat -c '%C' "$target_path" 2>/dev/null)"
  [ "$context" = "?" ] && context=""
  {
    printf 'target=%s\n' "$target_path"
    [ -n "$uid" ] && printf 'uid=%s\n' "$uid"
    [ -n "$gid" ] && printf 'gid=%s\n' "$gid"
    [ -n "$mode" ] && printf 'mode=%s\n' "$mode"
    [ -n "$context" ] && printf 'context=%s\n' "$context"
  } > "$meta_path"
}

restore_file_metadata() {
  local target_path meta_path uid gid mode context
  target_path="$1"
  meta_path="$2"
  [ -f "$meta_path" ] || return 0
  uid="$(sed -n 's/^uid=//p' "$meta_path" | head -n 1)"
  gid="$(sed -n 's/^gid=//p' "$meta_path" | head -n 1)"
  mode="$(sed -n 's/^mode=//p' "$meta_path" | head -n 1)"
  context="$(sed -n 's/^context=//p' "$meta_path" | head -n 1)"
  [ -n "$uid" ] && [ -n "$gid" ] && chown "$uid:$gid" "$target_path" 2>/dev/null
  [ -n "$mode" ] && chmod "$mode" "$target_path" 2>/dev/null
  [ -n "$context" ] && chcon "$context" "$target_path" 2>/dev/null
}

backup_data_font_once() {
  local target_path backup_path meta_path
  target_path="$1"
  [ -f "$target_path" ] || return 1
  files_are_same "$target_path" "$FONT_PATH" && return 0

  mkdir -p "$DATA_FONT_BACKUP_DIR" 2>/dev/null || return 1
  backup_path="$(data_font_backup_path_for "$target_path")"
  meta_path="$backup_path.meta"

  if [ ! -f "$backup_path" ]; then
    cp -p "$target_path" "$backup_path" 2>/dev/null || cp -f "$target_path" "$backup_path" 2>/dev/null || return 1
    capture_file_metadata "$target_path" "$meta_path"
    append_log "INFO: Backed up data emoji font: $target_path"
  fi

  append_unique_line "$DATA_FONT_BACKUP_MANIFEST" "$backup_path|$target_path"
  return 0
}

bind_mount_font() {
  local target_path
  target_path="$1"
  [ -f "$target_path" ] || return 1
  umount "$target_path" >/dev/null 2>&1
  mount -o bind "$FONT_PATH" "$target_path" >/dev/null 2>&1 && return 0
  mount --bind "$FONT_PATH" "$target_path" >/dev/null 2>&1 && return 0
  return 1
}

apply_data_font_override() {
  local target_path
  target_path="$1"
  [ -f "$target_path" ] || return 1
  ensure_font_payload || return 1

  umount "$target_path" >/dev/null 2>&1
  backup_data_font_once "$target_path" || append_log "WARN: Could not back up data emoji font: $target_path"
  cp -f "$FONT_PATH" "$target_path" 2>/dev/null || return 1
  chmod 0644 "$target_path" 2>/dev/null
  bind_mount_font "$target_path" || append_log "WARN: Bind mount unavailable for $target_path; copied font remains"
  return 0
}

extract_package_from_data_path() {
  printf '%s\n' "$1" | sed -n 's#^/data/data/\([^/]*\)/.*#\1#p'
}

foreground_package() {
  local package_name
  package_name="$(dumpsys activity activities 2>/dev/null | sed -n 's/.*topResumedActivity.* \([^ /]*\)\/.*/\1/p' | head -n 1)"
  [ -n "$package_name" ] && {
    echo "$package_name"
    return 0
  }
  package_name="$(dumpsys window 2>/dev/null | sed -n 's/.*mCurrentFocus=.* \([^ /]*\)\/.*/\1/p' | head -n 1)"
  [ -n "$package_name" ] && echo "$package_name"
}

is_protected_installer_package() {
  local package_name protected_package
  package_name="$1"
  for protected_package in $PROTECTED_INSTALLER_PACKAGES; do
    [ "$package_name" = "$protected_package" ] && return 0
  done
  return 1
}

should_skip_package_replacement() {
  local package_name active_package
  package_name="$1"
  active_package="$2"
  [ "$MODE_ARG" = "install" ] || return 1
  [ -n "$package_name" ] || return 1
  [ -n "$active_package" ] && [ "$package_name" = "$active_package" ] && return 0
  is_protected_installer_package "$package_name"
}

begin_runtime_tracking() {
  mkdir -p "$STATE_DIR" 2>/dev/null
  : > "$RUN_DATA_FONT_PATHS_FILE"
  : > "$RUN_TOUCHED_PACKAGES_FILE"
}

finalize_runtime_tracking() {
  [ -f "$RUN_DATA_FONT_PATHS_FILE" ] && mv -f "$RUN_DATA_FONT_PATHS_FILE" "$DATA_FONT_PATHS_FILE" 2>/dev/null
  [ -f "$RUN_TOUCHED_PACKAGES_FILE" ] && mv -f "$RUN_TOUCHED_PACKAGES_FILE" "$TOUCHED_PACKAGES_FILE" 2>/dev/null
}

replace_data_emoji_fonts() {
  local candidate_file source_path package_name active_package scanned replaced failed skipped
  scanned=0
  replaced=0
  failed=0
  skipped=0
  active_package=""

  [ -d /data/data ] || return 0
  ensure_font_payload || return 0
  [ "$MODE_ARG" = "install" ] && active_package="$(foreground_package)"

  candidate_file="$STATE_DIR/data-font-candidates.$$"
  find_emoji_font_candidates /data/data > "$candidate_file"

  while IFS= read -r source_path; do
    [ -n "$source_path" ] || continue
    scanned=$((scanned + 1))
    package_name="$(extract_package_from_data_path "$source_path")"

    if should_skip_package_replacement "$package_name" "$active_package"; then
      skipped=$((skipped + 1))
      append_log "INFO: Skipped installer-host data font: $source_path"
      continue
    fi

    if apply_data_font_override "$source_path"; then
      replaced=$((replaced + 1))
      append_unique_line "$RUN_DATA_FONT_PATHS_FILE" "$source_path"
      append_unique_line "$RUN_TOUCHED_PACKAGES_FILE" "$package_name"
      ui_note "- UniEmoji: replaced data font $source_path"
      append_log "INFO: Replaced data emoji font: $source_path"
    else
      failed=$((failed + 1))
      append_log "WARN: Failed data emoji replacement: $source_path"
    fi
  done < "$candidate_file"

  rm -f "$candidate_file" 2>/dev/null
  append_log "INFO: Data scan summary: scanned=$scanned replaced=$replaced failed=$failed skipped=$skipped"
}

package_installed() {
  pm list packages 2>/dev/null | grep -q "^package:$1$"
}

clear_package_cache() {
  local package_name cache_dir
  package_name="$1"
  [ "$MODE_ARG" = "install" ] && return 0
  [ -n "$package_name" ] && package_installed "$package_name" || return 0

  for cache_dir in "/data/data/$package_name/cache" "/data/data/$package_name/code_cache" "/data/data/$package_name/app_webview" "/data/data/$package_name/files/GCache"; do
    [ -d "$cache_dir" ] && rm -rf "$cache_dir" 2>/dev/null
  done

  [ "$package_name" = "com.google.android.gms" ] && return 0
  am force-stop "$package_name" >/dev/null 2>&1
}

clear_known_caches() {
  local package_name
  [ -f "$RUN_TOUCHED_PACKAGES_FILE" ] || return 0
  while IFS= read -r package_name; do
    [ -n "$package_name" ] && clear_package_cache "$package_name"
  done < "$RUN_TOUCHED_PACKAGES_FILE"
}

cleanup_runtime_font_dirs() {
  [ -d /data/fonts ] && rm -rf /data/fonts 2>/dev/null
}

restore_saved_data_font_overrides() {
  local target_path restored failed missing
  restored=0
  failed=0
  missing=0
  [ -f "$DATA_FONT_PATHS_FILE" ] || return 0
  ensure_font_payload || return 0

  while IFS= read -r target_path; do
    [ -n "$target_path" ] || continue
    if [ ! -f "$target_path" ]; then
      missing=$((missing + 1))
      continue
    fi
    if apply_data_font_override "$target_path"; then
      restored=$((restored + 1))
    else
      failed=$((failed + 1))
    fi
  done < "$DATA_FONT_PATHS_FILE"

  append_log "INFO: Saved data font restore summary: restored=$restored failed=$failed missing=$missing"
}

restore_data_font_backups() {
  local manifest_line backup_path target_path meta_path restored failed missing
  restored=0
  failed=0
  missing=0
  [ -f "$DATA_FONT_BACKUP_MANIFEST" ] || return 0

  while IFS= read -r manifest_line; do
    [ -n "$manifest_line" ] || continue
    backup_path="${manifest_line%%|*}"
    target_path="${manifest_line#*|}"
    meta_path="$backup_path.meta"

    if [ ! -f "$backup_path" ] || [ ! -f "$target_path" ]; then
      missing=$((missing + 1))
      continue
    fi

    umount "$target_path" >/dev/null 2>&1
    if cp -f "$backup_path" "$target_path" 2>/dev/null; then
      restore_file_metadata "$target_path" "$meta_path"
      restored=$((restored + 1))
    else
      failed=$((failed + 1))
    fi
  done < "$DATA_FONT_BACKUP_MANIFEST"

  append_log "INFO: Backup restore summary: restored=$restored failed=$failed missing=$missing"
}

build_package_snapshot() {
  local package_name version_code package_paths
  : > "$PACKAGE_SNAPSHOT_CURRENT_FILE"
  [ -f "$TOUCHED_PACKAGES_FILE" ] || return 0
  while IFS= read -r package_name; do
    [ -n "$package_name" ] || continue
    package_installed "$package_name" || continue
    version_code="$(dumpsys package "$package_name" 2>/dev/null | sed -n 's/.*versionCode=\([0-9][0-9]*\).*/\1/p' | head -n 1)"
    package_paths="$(pm path "$package_name" 2>/dev/null | sed 's/^package://')"
    printf '%s|%s|%s\n' "$package_name" "${version_code:-unknown}" "$package_paths" >> "$PACKAGE_SNAPSHOT_CURRENT_FILE"
  done < "$TOUCHED_PACKAGES_FILE"
}

packages_have_changed() {
  local current previous
  build_package_snapshot
  current="$(cat "$PACKAGE_SNAPSHOT_CURRENT_FILE" 2>/dev/null)"
  previous="$(cat "$PACKAGE_SNAPSHOT_FILE" 2>/dev/null)"
  [ -n "$current" ] && [ "$current" != "$previous" ]
}

persist_package_snapshot() {
  build_package_snapshot
  mv -f "$PACKAGE_SNAPSHOT_CURRENT_FILE" "$PACKAGE_SNAPSHOT_FILE" 2>/dev/null
}

acquire_run_lock() {
  mkdir -p "$STATE_DIR" 2>/dev/null
  mkdir "$LOCKDIR" 2>/dev/null && {
    printf '%s\n' "$$" > "$LOCKDIR/pid"
    return 0
  }
  return 1
}

release_run_lock() {
  rm -rf "$LOCKDIR" 2>/dev/null
}

acquire_scheduler_lock() {
  local old_pid
  mkdir -p "$STATE_DIR" 2>/dev/null
  if mkdir "$SCHEDULER_LOCKDIR" 2>/dev/null; then
    printf '%s\n' "$$" > "$SCHEDULER_LOCKDIR/pid"
    return 0
  fi

  old_pid="$(cat "$SCHEDULER_LOCKDIR/pid" 2>/dev/null)"
  if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
    return 1
  fi

  rm -rf "$SCHEDULER_LOCKDIR" 2>/dev/null
  mkdir "$SCHEDULER_LOCKDIR" 2>/dev/null || return 1
  printf '%s\n' "$$" > "$SCHEDULER_LOCKDIR/pid"
  return 0
}

release_scheduler_lock() {
  rm -rf "$SCHEDULER_LOCKDIR" 2>/dev/null
}

run_repair() {
  [ -f "$UNINSTALLING_FLAG" ] && return 0
  determine_mount_mode
  append_log "INFO: UniEmoji repair started trigger=$TRIGGER_REASON root=$ROOT_SOLUTION mount=$MOUNT_MODE mode=$MODE_ARG"
  update_public_status "Running UniEmoji repair: trigger=$TRIGGER_REASON, root=$ROOT_SOLUTION, mount=$MOUNT_MODE"
  begin_runtime_tracking
  ensure_font_payload || {
    update_public_status "UniEmoji skipped: missing Emoji*.ttf"
    return 0
  }
  replace_system_emoji_fonts
  replace_data_emoji_fonts
  cleanup_runtime_font_dirs
  clear_known_caches
  finalize_runtime_tracking
  persist_package_snapshot
  update_public_status "Completed UniEmoji repair: root=$ROOT_SOLUTION, mount=$MOUNT_MODE"
  append_log "INFO: UniEmoji repair finished"
}

run_scheduler() {
  local burst_run current_epoch last_action_epoch
  local interval_seconds check_interval_seconds boot_burst_runs boot_burst_interval_seconds

  interval_seconds=3600
  check_interval_seconds=300
  boot_burst_runs=5
  boot_burst_interval_seconds=60

  ensure_public_paths
  if ! acquire_scheduler_lock; then
    append_log "INFO: UniEmoji scheduler skipped because another scheduler is running"
    return 0
  fi
  trap 'release_scheduler_lock' EXIT

  while [ "$(getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
    sleep 5
  done

  while [ ! -d /sdcard ]; do
    sleep 5
  done

  append_log "INFO: UniEmoji scheduler started"
  last_action_epoch=0
  burst_run=1
  while [ "$burst_run" -le "$boot_burst_runs" ]; do
    TRIGGER_REASON="boot-burst-$burst_run"
    run_repair
    last_action_epoch="$(date +%s)"
    [ "$burst_run" -lt "$boot_burst_runs" ] && sleep "$boot_burst_interval_seconds"
    burst_run=$((burst_run + 1))
  done

  while true; do
    sleep "$check_interval_seconds"
    current_epoch="$(date +%s)"

    if packages_have_changed; then
      TRIGGER_REASON="package-update"
      run_repair
      last_action_epoch="$current_epoch"
      continue
    fi

    if [ $((current_epoch - last_action_epoch)) -ge "$interval_seconds" ]; then
      TRIGGER_REASON="hourly"
      run_repair
      last_action_epoch="$current_epoch"
    fi
  done
}

case "$MODE_ARG" in
  install)
    ensure_public_paths
    if acquire_run_lock; then
      trap 'release_run_lock' EXIT
      run_repair
    else
      append_log "INFO: Install repair skipped because another UniEmoji repair is running"
    fi
    ;;
  post-fs-data)
    ensure_public_paths
    determine_mount_mode
    ensure_font_payload
    restore_saved_data_font_overrides
    cleanup_runtime_font_dirs
    update_public_status "UniEmoji post-fs-data completed: root=$ROOT_SOLUTION, mount=$MOUNT_MODE"
    ;;
  uninstall)
    ensure_public_paths
    mkdir -p "$STATE_DIR" 2>/dev/null
    : > "$UNINSTALLING_FLAG"
    if acquire_run_lock; then
      trap 'release_run_lock' EXIT
      restore_data_font_backups
    else
      restore_data_font_backups
    fi
    update_public_status "UniEmoji uninstall restore completed"
    ;;
  has-package-changes)
    packages_have_changed
    exit $?
    ;;
  scheduler)
    run_scheduler
    ;;
  runtime|*)
    ensure_public_paths
    if acquire_run_lock; then
      trap 'release_run_lock' EXIT
      run_repair
    else
      append_log "INFO: Runtime repair skipped because another UniEmoji repair is running"
    fi
    ;;
esac

exit 0
UNIEMOJI_HELPER
}

ue_install_hooks() {
  ue_append_hook "$MODPATH/action.sh" "MFFM UniEmoji action hook" "runtime" "manual"
  ue_append_hook "$MODPATH/service.sh" "MFFM UniEmoji service hook" "scheduler" "service" "background"
  ue_append_hook "$MODPATH/boot-completed.sh" "MFFM UniEmoji boot-completed hook" "scheduler" "boot-completed" "background"
  ue_append_hook "$MODPATH/post-fs-data.sh" "MFFM UniEmoji post-fs-data hook" "post-fs-data" "boot"
  ue_append_hook "$MODPATH/uninstall.sh" "MFFM UniEmoji uninstall hook" "uninstall" "uninstall"
}

uniemoji() {
  local source_font

  [ -n "$MODPATH" ] || {
    ue_ui "- UniEmoji: MODPATH is not set; skipping."
    return 0
  }

  source_font="$(ue_first_emoji_font)" || {
    ue_ui "- UniEmoji: Emoji*.ttf not found; skipping."
    return 0
  }

  ue_ui ""
  ue_ui "- UniEmoji: installing custom emoji payload."
  ue_ui "  Source: $(basename "$source_font")"

  ue_write_runtime_helper
  ue_install_hooks

  ORISYSFONT="$ORISYSFONT" \
  ORIPRDFONT="$ORIPRDFONT" \
  ORISYSEXT="$ORISYSEXT" \
  FONTDIR="$FONTDIR" \
  MFFM="$MFFM" \
  sh "$MODPATH/scripts/mffm-uniemoji.sh" install "module-install"
}

uniemoji
