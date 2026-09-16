#!/system/bin/sh
# Maxregner OS 2.0 — post-fs-data boot hook.
# Runs at the post-fs-data stage under Magisk. Sets the ro.maxregner.glass.*
# flags that the firmware-injected Lio/mesalabs/unica/MaxregnerGlass; helper
# reads at class-init, and forces the window-blur renderer on. The RRO overlay
# shipped under system/product/overlay/ is picked up by the framework from the
# module's magisk system mirror, so no manual overlay registration is needed.

# The glass enable flag read by MaxregnerGlass.shouldForceBlur().
setprop ro.maxregner.glass.enabled true
setprop ro.maxregner.glass.blur_radius 32
setprop ro.maxregner.glass.rounded true

# Force the system window-blur renderer on. These setprops are applied at
# post-fs-data so SurfaceFlinger reads them before the first frame is drawn.
setprop ro.surface_flinger.supports_background_blur true
setprop debug.sf.use_blur_path true 2>/dev/null

# Mark the maxregner on-top OS layer as active for the Maxregner settings panel.
setprop ro.maxregner.os.active true
