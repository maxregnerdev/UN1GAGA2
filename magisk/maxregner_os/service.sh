#!/system/bin/sh
# Maxregner OS 2.0 — late-boot service hook.
# Runs in the service (late_start) stage under Magisk, after the framework is
# up. Re-checks the glass flags (in case something reset them between
# post-fs-data and boot) and logs activation so the user can verify the
# on-top layer is live via `getprop ro.maxregner.os.active`.
setprop ro.maxregner.glass.enabled true 2>/dev/null
setprop ro.maxregner.os.active true 2>/dev/null
log -t MaxregnerOS "Glass layer active (v39)"
