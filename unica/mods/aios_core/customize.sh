# AI OS v0.1 Core
# Registers the on-device AI engine and smart feature subsystem so the
# framework exposes AI OS capabilities via ro.aios.* system properties and
# ties the AI core into the maxregner core integration layer.

LOG_STEP_IN "- Applying AI OS core"

# AI engine identity and version
SET_PROP "system" "ro.aios.core.enabled" "true"
SET_PROP "system" "ro.aios.core.engine" "maxregner"
SET_PROP "system" "ro.aios.core.version" "1.0"
SET_PROP "system" "persist.sys.aios.core.mode" "adaptive"

# Smart feature subsystems
SET_PROP "system" "ro.aios.smart.enabled" "true"
SET_PROP "system" "ro.aios.smart.assistant" "true"
SET_PROP "system" "ro.aios.smart.notif_summary" "true"
SET_PROP "system" "ro.aios.smart.battery" "true"
SET_PROP "system" "ro.aios.smart.text_predict" "true"
SET_PROP "system" "ro.aios.smart.app_predict" "true"
SET_PROP "system" "ro.aios.smart.scroll" "true"
SET_PROP "system" "ro.aios.smart.screen_off" "true"

# On-device intelligence preferences
SET_PROP "system" "persist.sys.aios.intelligence.level" "balanced"
SET_PROP "system" "persist.sys.aios.intelligence.learning" "true"
SET_PROP "system" "persist.sys.aios.privacy.on_device" "true"

# Maxregner core integration (the AI core uses the maxregner navigation +
# design surface as its input layer)
SET_PROP "system" "ro.aios.nav.system" "maxregner_orb"
SET_PROP "system" "ro.aios.ui.system" "maxregner_ui"
SET_PROP "system" "ro.aios.sound.system" "maxregner_sound"

LOG_STEP_OUT
