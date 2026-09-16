#!/sbin/sh
# Maxregner OS 2.0 — Magisk module installer entry point.
# This is the standard Magisk module flow: Magisk sources this file and
# expects it to print module.prop metadata and a finish message.

SKIPUNZIP=0

# ui_print is provided by the Magisk environment when this runs in recovery.
if ! command -v ui_print >/dev/null 2>&1; then
    ui_print() { echo "$1"; }
fi

ui_print " "
ui_print "  Maxregner OS 2.0 (v39)"
ui_print "  On-top glass + spatial subsystem layer"
ui_print " "
ui_print "- Subsystems: Glass, Spatial, Orb v3, Flux, Aero, Aura,"
ui_print "  Synth, Vault, Cloud"
ui_print "- Setting ro.maxregner.* flags at post-fs-data"
ui_print "- Shipping unified RRO overlay"
ui_print " "
