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

OVERLAYS="com.maxregner.ui.overlay com.maxregner.nav.overlay com.maxregner.extras.overlay"

# wait for the overlay service
i=0
while [ "$i" -lt 30 ]; do
    if cmd overlay list >/dev/null 2>&1; then
        break
    fi
    sleep 1
    i=$((i + 1))
done

for pkg in $OVERLAYS; do
    # enable: make it the default + enable it
    cmd overlay enable "$pkg" 2>/dev/null
    cmd overlay set-priority "$pkg" 100 2>/dev/null
done
