# Maxregner UI Design System
#
# Recodes the One UI visual surface to the Maxregner design language:
#   - a cohesive Maxregner color palette (light + dark)
#   - a unified shape/corner radius scale
#   - a motion (durations/easings) token set
#   - typography defaults (the Maxregner type ramp)
#
# Tokens are shipped as an overlay resource package plus a JSON token file at
# /system/etc/maxregner/tokens.json so the native Maxregner components can read
# them without depending on resource IDs.

LOG_STEP_IN "- Applying Maxregner UI design system"

# Advertise the active Maxregner design variant system-wide.
SET_PROP "system" "ro.maxregner.ui.enabled" "true"
SET_PROP "system" "ro.maxregner.ui.variant" "default"
SET_PROP "system" "persist.sys.maxregner.ui.accent" "#3B82F6"
SET_PROP "system" "persist.sys.maxregner.ui.corner_radius" "20"
SET_PROP "system" "persist.sys.maxregner.ui.motion" "fluid"
SET_PROP "system" "persist.sys.maxregner.ui.blur_strength" "0.9"

LOG_STEP_OUT
