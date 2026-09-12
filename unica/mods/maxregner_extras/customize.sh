# Maxregner Extras
#
# Extends the Maxregner system with:
#   - the Maxregner Sans font (registered as a custom FlipFont family so it can
#     be selected in Display settings via the existing monotype mod path)
#   - AOD / lockscreen Maxregner theming props
#   - launcher gesture hooks that route to the Maxregner Orb
#   - advanced system feature flags

LOG_STEP_IN "- Applying Maxregner extras"

# --- Maxregner Sans font ---
# Advertise the Maxregner type family system-wide. The actual font binary
# (maxregner_sans.ttf) lives under system/system/product/fonts/.
SET_PROP "system" "ro.maxregner.font.family" "maxregner_sans"
SET_PROP "system" "persist.sys.maxregner.font.enabled" "true"

# --- AOD / lockscreen ---
SET_PROP "system" "ro.maxregner.aod.enabled" "true"
SET_PROP "system" "persist.sys.maxregner.aod.theme" "orb"
SET_PROP "system" "persist.sys.maxregner.lockscreen.accent" "#6366F1"

# --- Launcher gestures routed through the Orb ---
SET_PROP "system" "persist.sys.maxregner.launcher.swipe_up" "orb_recents"
SET_PROP "system" "persist.sys.maxregner.launcher.swipe_down" "notifications"
SET_PROP "system" "persist.sys.maxregner.launcher.long_press_home" "assistant"

# --- Advanced system features ---
SET_PROP "system" "persist.sys.maxregner.always_show_time_aod" "true"
SET_PROP "system" "persist.sys.maxregner.smooth_scroll" "true"
SET_PROP "system" "persist.sys.maxregner.rounded_corners" "28"

LOG_STEP_OUT
