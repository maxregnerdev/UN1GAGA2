# Maxregner Orb Navigation v2
#
# The Maxregner Orb v2 replaces the classic 3-button nav bar and the gesture
# pill with a single glassmorphic adaptive floating orb. New v2 behaviors:
#   - radial menu (long-hold) with Back/Home/Recents/Notifications/Screenshot/Assistant
#   - magnetic docking zones on bottom/left/right edges (start/center/end slots)
#   - two-finger pinch/spread to enter/exit split-screen
#   - corner flicks (up-left = one-handed, up-right = split-screen)
#   - contextual morphing (typing → back glyph, recents → recents glyph)
#   - idle "breath" animation that fades on interaction
#
# This mod configures the framework to expose the Maxregner v2 navigation mode
# and ships the runtime overlay + sysconfig that describe the orb surface to
# the rest of the system.

LOG_STEP_IN "- Activating Maxregner Orb navigation v2"

# Framework: advertise the Maxregner v2 navigation mode as a first-class nav type.
SET_PROP "system" "ro.maxregner.nav.enabled" "true"
SET_PROP "system" "ro.maxregner.nav.mode" "orb"
SET_PROP "system" "ro.maxregner.nav.version" "2"
SET_PROP "system" "ro.maxregner.nav.orb_scale" "1.0"
SET_PROP "system" "ro.maxregner.nav.orb_adaptive" "true"

# v2 feature flags.
SET_PROP "system" "ro.maxregner.nav.radial_menu" "true"
SET_PROP "system" "ro.maxregner.nav.magnetic_snap" "true"
SET_PROP "system" "ro.maxregner.nav.split_gestures" "true"
SET_PROP "system" "ro.maxregner.nav.idle_breath" "true"
SET_PROP "system" "ro.maxregner.nav.contextual_morph" "true"
SET_PROP "system" "ro.maxregner.nav.glass_effect" "true"

# Tunables (user-adjustable from Settings).
SET_PROP "system" "persist.sys.maxregner.nav.enabled" "true"
SET_PROP "system" "persist.sys.maxregner.nav.gesture_sensitivity" "1"
SET_PROP "system" "persist.sys.maxregner.nav.haptic_feedback" "true"
SET_PROP "system" "persist.sys.maxregner.nav.dwell_threshold_ms" "180"
SET_PROP "system" "persist.sys.maxregner.nav.long_hold_ms" "450"
SET_PROP "system" "persist.sys.maxregner.nav.radial_radius_dp" "96"
SET_PROP "system" "persist.sys.maxregner.nav.snap_radius_dp" "16"
SET_PROP "system" "persist.sys.maxregner.nav.idle_period_ms" "4200"

# Hide the legacy navigation bar once the Orb is active: the orb is an overlay
# and does not need the SystemUI navigation bar surface.
SET_PROP "system" "persist.sys.maxregner.nav.hide_legacy_bar" "true"

# Keep stock gesture navigation available as a fallback for accessibility, but
# let Settings present the Maxregner Orb as the default entry.
SET_PROP "system" "ro.maxregner.nav.fallback_gestures" "true"

LOG_STEP_OUT
