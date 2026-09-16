# Maxregner Aero (maxregner_aero) — real firmware injection
#
# The 0001-Introduce-MaxregnerAero.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerAero; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class is the real motion engine:
# it reads ro.maxregner.aero.* props and exposes the Maxregner easing curves
# (easeStandard / easeEmphasized / easeOvershoot — cubic + spring families),
# a smoothstep gate, and a seeded value-noise generator for ambient motion.
# The window/transition animators route their interpolation through these.

LOG_STEP_IN "- Injecting Maxregner Aero motion engine"

# Aero enable flag read by MaxregnerAero.readEnabled().
SET_PROP "system" "ro.maxregner.aero.enabled" "true"
SET_PROP "system" "ro.maxregner.aero.motion_scale" "1.0"
SET_PROP "system" "ro.maxregner.aero.overshoot" "true"
SET_PROP "system" "ro.maxregner.aero.ambient_noise" "true"

LOG_STEP_OUT
