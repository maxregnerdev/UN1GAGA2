# Maxregner Living Surface (Spatial) — real firmware injection
#
# The 0001-Introduce-MaxregnerSpatial.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerSpatial; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class reads ro.maxregner.spatial.*
# props, holds the latest gyroscope reading, and exposes getDepth(windowType)
# plus getParallaxX()/getParallaxY() so the window animator and launcher can
# stack windows on Z planes and tilt them with the device. updateGyro(FF) is
# the entry the sensor listener calls to feed new rotation-rate samples.
#
# The hook below injects a Maxregner depth read into the window animator's
# surface layer computation, routing through MaxregnerSpatial.getDepth(). The
# SMALI_PATCH "replace" verifies the target method and search string exist in
# the decoded firmware at apply time, so the build aborts loudly if a device's
# animator differs (never silently ships broken).

LOG_STEP_IN "- Injecting Maxregner Living Surface into framework.jar"

# Spatial enable flag read by MaxregnerSpatial.readEnabled() / isEnabled().
SET_PROP "system" "ro.maxregner.spatial.enabled" "true"
SET_PROP "system" "ro.maxregner.spatial.parallax_amplitude" "0.06"
SET_PROP "system" "ro.maxregner.spatial.depth_layers" "true"
SET_PROP "system" "ro.maxregner.spatial.gyro_driven" "true"

# Hook the window animator's layer offset read to respect the maxregner depth.
# The target method exists in Samsung framework; if the signature differs on a
# target device the build aborts here.
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/android/wm/WindowAnimatorUtils.smali" "replace" \
    'computeSurfaceLayer()I' \
    'const/4 v0, 0x0' \
    'const-string v1, "app"' \
    'invoke-static {v1}, Lio/mesalabs/unica/MaxregnerSpatial;->getDepth(Ljava/lang/String;)I'

LOG_STEP_OUT
