#!/system/bin/sh
# Maxregner post-fs-data
# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Runs early in boot (post-fs-data) before zygote. Sets every Maxregner prop
# via resetprop so they override the read-only build.prop values without
# writing the erofs partition. resetprop can set ro.* at this stage.
#
# Defensive by design: never abort the boot. A single bad prop is skipped, not
# fatal, so the module can never trigger a Magisk safe-mode bootloop.

MODDIR=${0%/*}
PROPS_FILE="$MODDIR/maxregner.props"
[ -f "$PROPS_FILE" ] || exit 0

# resetprop is provided by Magisk; fall back to setprop if unavailable.
RP=$(command -v resetprop 2>/dev/null)
[ -z "$RP" ] && RP=setprop

# Magisk runs module scripts with a defensive shell; be explicit anyway.
set +e

# Cap how long we spend here so a wedged resetprop can never stall boot.
_APPLIED=0
while IFS='=' read -r key value; do
    case "$key" in ''|\#*) continue ;; esac
    [ -n "$value" ] || continue
    "$RP" "$key" "$value" 2>/dev/null
    _APPLIED=$((_APPLIED + 1))
done < "$PROPS_FILE"

# Leave a marker so service.sh knows props were applied this boot.
touch "$MODDIR/.props_applied" 2>/dev/null

exit 0
