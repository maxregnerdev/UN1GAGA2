#!/sbin/sh
# Maxregner OS 2.0 — Magisk module installer entry point.
# This is the standard Magisk module flow: Magisk sources this file and
# expects it to print module.prop metadata and a finish message.
SKIPUNZIP=0

# ui_print is provided by the Magisk environment when this runs in recovery.
if ! command -v ui_print >/dev/null 2>&1; then
    ui_print() { echo "$1"; }
fi

ui_print "- Maxregner OS 2.0 (Glass)"
ui_print "- Installing on-top glass layer"
