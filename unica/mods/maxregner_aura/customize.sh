# Maxregner Aura (maxregner_aura) — real firmware injection
#
# The 0001-Introduce-MaxregnerAura.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerAura; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class is the real ambient-light
# color-temperature engine: it reads ro.maxregner.aura.* props, maps ambient
# lux to a target white point in Kelvin via luxToKelvin(), eases the current
# Kelvin toward the target with step(alpha), and converts Kelvin to an RGB
# white-balance triplet via kelvinToRGB(kelvin, out[3]) so the display
# compositor can tint the surface to match the room light.

LOG_STEP_IN "- Injecting Maxregner Aura ambient-light engine"

# Aura enable flag read by MaxregnerAura.readEnabled().
SET_PROP "system" "ro.maxregner.aura.enabled" "true"
SET_PROP "system" "ro.maxregner.aura.adaptive_kelvin" "true"
SET_PROP "system" "ro.maxregner.aura.min_kelvin" "2500"
SET_PROP "system" "ro.maxregner.aura.max_kelvin" "7500"
SET_PROP "system" "ro.maxregner.aura.ease_alpha" "0.08"

LOG_STEP_OUT
