#!/system/bin/sh
# Maxregner OS 2.0 — late-boot service hook.
# Runs in the service (late_start) stage under Magisk, after the framework is
# up. Re-asserts the core enable flags (in case something reset them between
# post-fs-data and boot) and logs activation so the user can verify the
# on-top layer is live via `getprop ro.maxregner.os.active`.

# Re-assert the master switches for every subsystem.
setprop ro.maxregner.glass.enabled true 2>/dev/null
setprop ro.maxregner.spatial.enabled true 2>/dev/null
setprop ro.maxregner.orb3.enabled true 2>/dev/null
setprop ro.maxregner.flux.enabled true 2>/dev/null
setprop ro.maxregner.aero.enabled true 2>/dev/null
setprop ro.maxregner.aura.enabled true 2>/dev/null
setprop ro.maxregner.synth.enabled true 2>/dev/null
setprop ro.maxregner.vault.enabled true 2>/dev/null
setprop ro.maxregner.cloud.enabled true 2>/dev/null
setprop ro.maxregner.os.active true 2>/dev/null

log -t MaxregnerOS "OS 2.0 active (v39): glass spatial orb3 flux aero aura synth vault cloud"
