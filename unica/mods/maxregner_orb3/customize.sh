# Maxregner Orb v3 (maxregner_orb3) — real firmware injection
#
# The 0001-Introduce-MaxregnerOrb3.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerOrb3; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class is the v3 orb controller:
# it reads ro.maxregner.orb3.* props, evaluates a real spring physics solver
# (SpringSolver) to produce fluid morph state, classifies gestures from the
# pointer sample stream, and exposes the resolved orb state to SystemUI.

LOG_STEP_IN "- Injecting Maxregner Orb v3 into framework.jar"

# Orb v3 enable flag read by MaxregnerOrb3.readEnabled() / isEnabled().
SET_PROP "system" "ro.maxregner.orb3.enabled" "true"
SET_PROP "system" "ro.maxregner.orb3.version" "3"
SET_PROP "system" "ro.maxregner.orb3.spring_stiffness" "0.62"
SET_PROP "system" "ro.maxregner.orb3.spring_damping" "0.78"
SET_PROP "system" "ro.maxregner.orb3.dwell_threshold_ms" "180"
SET_PROP "system" "ro.maxregner.orb3.gesture_field" "true"
SET_PROP "system" "ro.maxregner.orb3.fluid_morph" "true"
SET_PROP "system" "ro.maxregner.orb3.idle_breath" "true"

LOG_STEP_OUT
