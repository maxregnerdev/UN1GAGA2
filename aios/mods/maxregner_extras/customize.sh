# Maxregner Extras v2
#
# Extends the Maxregner system with:
#   - the Maxregner Sans font (registered as a custom FlipFont family so it can
#     be selected in Display settings via the existing monotype mod path)
#   - AOD / lockscreen Maxregner v2 theming (glassmorphic orb clock, glow pulse)
#   - launcher gesture hooks that route to the Maxregner Orb v2
#   - advanced system feature flags (v2: glass surfaces, overshoot, rounded)

LOG_STEP_IN "- Applying Maxregner extras v2"

# --- Maxregner Sans font ---
# Advertise the Maxregner type family system-wide. The actual font binary
# (maxregner_sans.ttf) lives under system/system/product/fonts/.
SET_PROP "system" "ro.maxregner.font.family" "maxregner_sans"
SET_PROP "system" "persist.sys.maxregner.font.enabled" "true"

# --- AOD / lockscreen (v2: glassmorphic orb clock) ---
SET_PROP "system" "ro.maxregner.aod.enabled" "true"
SET_PROP "system" "ro.maxregner.aod.version" "2"
SET_PROP "system" "persist.sys.maxregner.aod.theme" "orb"
SET_PROP "system" "persist.sys.maxregner.aod.glass" "true"
SET_PROP "system" "persist.sys.maxregner.lockscreen.accent" "#818CF8"

# --- Launcher gestures routed through the Orb v2 ---
SET_PROP "system" "persist.sys.maxregner.launcher.swipe_up" "orb_recents"
SET_PROP "system" "persist.sys.maxregner.launcher.swipe_down" "notifications"
SET_PROP "system" "persist.sys.maxregner.launcher.long_press_home" "assistant"
SET_PROP "system" "persist.sys.maxregner.launcher.swipe_up_left" "one_handed_mode"
SET_PROP "system" "persist.sys.maxregner.launcher.swipe_up_right" "splitscreen"

# --- Advanced system features (v2) ---
SET_PROP "system" "persist.sys.maxregner.always_show_time_aod" "true"
SET_PROP "system" "persist.sys.maxregner.smooth_scroll" "true"
SET_PROP "system" "persist.sys.maxregner.rounded_corners" "24"
SET_PROP "system" "persist.sys.maxregner.glass_surfaces" "true"
SET_PROP "system" "persist.sys.maxregner.overshoot_motion" "true"

LOG_STEP_OUT
