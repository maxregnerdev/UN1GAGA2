# Maxregner Glass — real firmware injection
#
# The 0001-Introduce-MaxregnerGlass.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerGlass; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class reads ro.maxregner.glass.*
# props and exposes shouldForceBlur() / shouldForceRounded() / getBlurRadius().
#
# The hook below rewrites the window-blur enable gate in
# com.samsung.android.rune.CoreRune so it returns the Maxregner flag value
# instead of the stock value. SMALI_PATCH "replace" verifies the method and
# the search string exist in the decoded firmware at apply time, so the build
# aborts loudly if a device's CoreRune differs (never silently ships broken).

LOG_STEP_IN "- Injecting Maxregner Glass into framework.jar"

# The blur enable flag read by MaxregnerGlass.shouldForceBlur().
SET_PROP "system" "ro.maxregner.glass.enabled" "true"
SET_PROP "system" "ro.maxregner.glass.blur_radius" "32"
SET_PROP "system" "ro.maxregner.glass.rounded" "true"

# Hook CoreRune.SUPPORT_WINDOW_BLUR to respect the maxregner flag. This is a
# real replace on a method that exists in Samsung framework; if the method
# signature differs on a target device the build aborts here.
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/rune/CoreRune.smali" "replace" \
    'SUPPORT_WINDOW_BLUR()Z' \
    'const/4 v0, 0x0' \
    'invoke-static {}, Lio/mesalabs/unica/MaxregnerGlass;->shouldForceBlur()Z'

LOG_STEP_OUT
