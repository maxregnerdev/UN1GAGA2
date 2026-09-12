# Maxregner Navigation
#
# The Maxregner Orb replaces the classic 3-button nav bar and the gesture-pill
# with a single adaptive floating orb. The orb is contextual: it morphs into
# Back, Home and Recents based on pressure/hold and directional flicks.
#
# This mod configures the framework to expose the Maxregner navigation mode and
# ships the runtime overlay + sysconfig that describe the orb surface to the
# rest of the system.

LOG_STEP_IN "- Activating Maxregner Orb navigation"

# Framework: advertise the Maxregner navigation mode as a first-class nav type.
SET_PROP "system" "ro.maxregner.nav.enabled" "true"
SET_PROP "system" "ro.maxregner.nav.mode" "orb"
SET_PROP "system" "ro.maxregner.nav.orb_scale" "1.0"
SET_PROP "system" "ro.maxregner.nav.orb_adaptive" "true"
SET_PROP "system" "persist.sys.maxregner.nav.gesture_sensitivity" "0.8"
SET_PROP "system" "persist.sys.maxregner.nav.haptic_feedback" "true"
SET_PROP "system" "persist.sys.maxregner.nav.dwell_threshold_ms" "180"

# Hide the legacy navigation bar once the Orb is active: the orb is an overlay
# and does not need the SystemUI navigation bar surface.
SET_PROP "system" "persist.sys.maxregner.nav.hide_legacy_bar" "true"

# Keep stock gesture navigation available as a fallback for accessibility, but
# let Settings present the Maxregner Orb as the default entry.
SET_PROP "system" "ro.maxregner.nav.fallback_gestures" "true"

LOG_STEP_OUT
