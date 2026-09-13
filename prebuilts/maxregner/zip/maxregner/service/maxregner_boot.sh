#!/system/bin/sh
# Maxregner boot service
# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Run at post-fs-data (Magisk/KernelSU service.d or module post-fs-data.sh).
# Activates the Maxregner system on top of a running UN1CA install whose
# partitions are mounted read-only erofs:
#
#   1. setprop every Maxregner prop (runtime props override read-only build.prop
#      values without writing the partition)
#   2. bind-mount the bundled Maxregner file overlays over the read-only
#      partition paths from /data/maxregner/system
#
# Idempotent: if a target is already bound to a Maxregner source, it is skipped.

MAXREGNER_DIR=${MAXREGNER_DIR:-/data/maxregner}
PROPS_FILE="$MAXREGNER_DIR/maxregner.props"
MAP_FILE="$MAXREGNER_DIR/file_map.txt"

log() { echo "maxregner: $*"; }

# POSIX sh has no 'local'; use _-prefixed names to avoid clobbering globals.

# --- 1. setprop every Maxregner prop ---
apply_props() {
    [ -f "$PROPS_FILE" ] || { log "no $PROPS_FILE, skipping props"; return 0; }
    # ro.* props set via setprop at boot stick for the whole boot session even
    # though the partition build.prop is read-only; persist.* props persist
    # across reboots through /data.
    while IFS='=' read -r key value; do
        case "$key" in ''|\#*) continue ;; esac
        [ -n "$value" ] || continue
        setprop "$key" "$value" 2>/dev/null || true
    done < "$PROPS_FILE"
    log "applied Maxregner props"
}

# --- 2. bind-mount Maxregner file overlays over read-only partition paths ---
is_mounted() {
    # returns 0 if $1 is already a bind mount source for $2
    awk -v src="$1" -v dst="$2" '
        $1 == src && $2 == dst && $4 ~ /bind/ { found=1 }
        END { exit !found }
    ' /proc/self/mounts 2>/dev/null
}

apply_overlays() {
    [ -f "$MAP_FILE" ] || { log "no $MAP_FILE, skipping overlays"; return 0; }
    _count=0
    while IFS='	' read -r src dst; do
        case "$src" in ''|\#*) continue ;; esac
        [ -n "$dst" ] || continue
        _full_src="$MAXREGNER_DIR/system$src"
        _full_dst="$dst"
        [ -f "$_full_src" ] || continue
        # create the target path (parent) if missing; the file itself may be
        # new (not present on the RO partition) so we touch it first.
        mkdir -p "${_full_dst%/*}" 2>/dev/null || true
        [ -e "$_full_dst" ] || { cp -a "$_full_src" "$_full_dst" 2>/dev/null || touch "$_full_dst" 2>/dev/null || true; }
        if is_mounted "$_full_src" "$_full_dst"; then
            continue
        fi
        if mount --bind "$_full_src" "$_full_dst" 2>/dev/null; then
            _count=$((_count + 1))
        fi
    done < "$MAP_FILE"
    log "applied $_count Maxregner overlays"
}

apply_props
apply_overlays

log "Maxregner boot service done"
