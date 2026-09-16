# Maxregner UI Design System v2
#
# Recodes the One UI visual surface to the Maxregner v2 design language:
#   - a tonal, wallpaper-driven semantic color system (light + dark)
#   - a unified shape/corner radius scale (none..xxl, full)
#   - an elevation level system + glass blur radii
#   - a motion token set (durations + standard/emphasized/overshoot easings)
#   - typography defaults (the Maxregner type ramp + tracking)
#
# Tokens are shipped as an overlay resource package plus a JSON token file at
# /system/etc/maxregner/tokens.json so the native Maxregner components can read
# them without depending on resource IDs. The native Maxregner tonal engine can
# extract the seed palette from the wallpaper when dynamic theming is enabled.

LOG_STEP_IN "- Applying Maxregner UI v2 design system"

# Advertise the active Maxregner design variant system-wide.
SET_PROP "system" "ro.maxregner.ui.enabled" "true"
SET_PROP "system" "ro.maxregner.ui.version" "2"
SET_PROP "system" "ro.maxregner.ui.variant" "tonal"

# Dynamic tonal theming: the Maxregner engine extracts the seed palette from the
# wallpaper and derives the full semantic surface set from it.
SET_PROP "system" "persist.sys.maxregner.ui.dynamic_theme" "true"
SET_PROP "system" "persist.sys.maxregner.ui.source_of_truth" "wallpaper"
SET_PROP "system" "persist.sys.maxregner.ui.contrast_level" "0"

# User-tunable accent override (empty = follow dynamic palette).
SET_PROP "system" "persist.sys.maxregner.ui.accent" ""
SET_PROP "system" "persist.sys.maxregner.ui.corner_radius" "16"
SET_PROP "system" "persist.sys.maxregner.ui.motion" "fluid"

# Glass / blur tuning.
SET_PROP "system" "persist.sys.maxregner.ui.blur_strength" "1.0"
SET_PROP "system" "persist.sys.maxregner.ui.blur_radius" "16"
SET_PROP "system" "persist.sys.maxregner.ui.glass_radius" "32"

# Overshoot motion is a Maxregner v2 signature: components settle with a light
# overshoot spring on state change.
SET_PROP "system" "persist.sys.maxregner.ui.overshoot_motion" "true"

LOG_STEP_OUT
