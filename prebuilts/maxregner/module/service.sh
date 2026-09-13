#!/system/bin/sh
# Maxregner service
# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Runs in late_start service. Enables the Maxregner RRO overlays so the
# OverlayManagerService applies them (palette, corners, navbar, AOD). The
# overlay APKs are already mounted by Magisk's systemless overlay at
# /system/product/overlay/ via the module's system/ tree; this just registers
# them as enabled.
#
# Defensive by design: if `cmd overlay` is unavailable, or any single enable
# fails, the script still exits 0 so it can never stall boot or trigger
# Magisk safe mode. Overlays are best-effort visual tweaks, not boot-critical.

MODDIR=${0%/*}

# If the overlays shipped by this module are missing, do nothing rather than
# risk poking the overlay service with nothing to apply.
OVERLAY_DIR="$MODDIR/system/product/overlay"
[ -d "$OVERLAY_DIR" ] || exit 0

set +e

OVERLAYS="com.maxregner.framework.overlay com.maxregner.ui.overlay com.maxregner.nav.overlay com.maxregner.extras.overlay com.maxregner.statusbar.overlay com.maxregner.launcher.overlay com.maxregner.icons.overlay com.maxregner.quicksettings.overlay com.maxregner.notifications.overlay"

# Wait for the overlay service, but never forever. 20s is enough on cold boot.
i=0
while [ "$i" -lt 20 ]; do
    if cmd overlay list >/dev/null 2>&1; then
        break
    fi
    sleep 1
    i=$((i + 1))
done

# If the service never came up, give up cleanly.
[ "$i" -ge 20 ] && exit 0

for pkg in $OVERLAYS; do
    cmd overlay enable "$pkg" 2>/dev/null
    cmd overlay set-priority "$pkg" 100 2>/dev/null
done

exit 0
