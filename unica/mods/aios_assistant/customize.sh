# AI OS v0.1 Assistant
# Configures the on-device assistant with its wake model, voice response
# theming and maxregner sound integration.

LOG_STEP_IN "- Applying AI OS assistant"

# Assistant identity and wake model
SET_PROP "system" "ro.aios.assistant.enabled" "true"
SET_PROP "system" "ro.aios.assistant.name" "Orion"
SET_PROP "system" "persist.sys.aios.assistant.wake_word" "hey orion"
SET_PROP "system" "persist.sys.aios.assistant.voice" "on-device"
SET_PROP "system" "persist.sys.aios.assistant.continuous" "true"

# Assistant theming tied to the maxregner UI design system
SET_PROP "system" "persist.sys.aios.assistant.accent" "#3B82F6"
SET_PROP "system" "persist.sys.aios.assistant.surface" "maxregner_ui"
SET_PROP "system" "persist.sys.aios.assistant.orb" "true"

# Assistant sounds use the maxregner sound scheme
SET_PROP "system" "persist.sys.aios.assistant.confirm_sound" "Maxregner_Tick"
SET_PROP "system" "persist.sys.aios.assistant.wake_sound" "Maxregner_OrbMorph"
SET_PROP "system" "persist.sys.aios.assistant.error_sound" "Maxregner_Swoosh"

# Context awareness
SET_PROP "system" "ro.aios.assistant.context_aware" "true"
SET_PROP "system" "persist.sys.aios.assistant.proactive" "true"

LOG_STEP_OUT
