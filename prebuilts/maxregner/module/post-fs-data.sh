#!/system/bin/sh
# Maxregner post-fs-data
# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Runs early in boot (post-fs-data) before zygote. Sets every Maxregner prop
# via resetprop so they override the read-only build.prop values without
# writing the erofs partition. resetprop can set ro.* at this stage.

MODDIR=${0%/*}
PROPS_FILE="$MODDIR/maxregner.props"

[ -f "$PROPS_FILE" ] || exit 0

# resetprop is provided by Magisk; fall back to setprop if unavailable.
RP=$(command -v resetprop 2>/dev/null)
[ -z "$RP" ] && RP=setprop

while IFS='=' read -r key value; do
    case "$key" in ''|\#*) continue ;; esac
    [ -n "$value" ] || continue
    "$RP" "$key" "$value" 2>/dev/null
done < "$PROPS_FILE"
