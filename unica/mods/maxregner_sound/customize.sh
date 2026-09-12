# Maxregner Sound Scheme
#
# Replaces the default Samsung/One UI sound set with the Maxregner sound
# scheme. The scheme is applied system-wide through the ro.config.* sound
# properties so that ringtones, notifications, alarms, the boot/power sound
# and UI effects all resolve to Maxregner assets.
#
# Audio binaries (.ogg) live alongside this script under
#   system/system/media/audio/{ui,notifications,ringtones,alarms}/
# Drop replacement assets into those folders; the build picks them up via the
# system/ tree addition performed by apply_modules.sh.
#
# Asset naming (all assets are referenced by the props below):
#   ui/         Maxregner_PowerOn.ogg          (boot / power on)
#   ui/         Maxregner_PowerOff.ogg         (shutdown)
#   ui/         Maxregner_Tick.ogg             (selection tick)
#   ui/         Maxregner_Swoosh.ogg           (transition)
#   ui/         Maxregner_OrbMorph.ogg         (orb morph, used by nav)
#   notifications/ Maxregner_Notice.ogg
#   ringtones/    Maxregner_Resonance.ogg
#   alarms/       Maxregner_Alarm.ogg

LOG_STEP_IN "- Applying Maxregner sound scheme"

# System-wide defaults (these are the props One UI reads for sound selection).
SET_PROP "vendor" "ro.config.ringtone" "Maxregner_Resonance.ogg"
SET_PROP "vendor" "ro.config.notification_sound" "Maxregner_Notice.ogg"
SET_PROP "vendor" "ro.config.alarm_alert" "Maxregner_Alarm.ogg"
SET_PROP "vendor" "ro.config.media_sound" "Maxregner_Resonance.ogg"
SET_PROP "vendor" "ro.config.ringtone_2" "Maxregner_Resonance.ogg"
SET_PROP "vendor" "ro.config.notification_sound_2" "Maxregner_Notice.ogg"

# Boot / power sound (consumed by the powersound service).
SET_PROP "system" "ro.config.power_on" "Maxregner_PowerOn.ogg"
SET_PROP "system" "ro.config.power_off" "Maxregner_PowerOff.ogg"

# Mark the Maxregner sound scheme as the active theme and advertise it.
SET_PROP "system" "ro.maxregner.sound.scheme" "maxregner"
SET_PROP "system" "ro.maxregner.sound.enabled" "true"
SET_PROP "system" "persist.sys.maxregner.sound.ui_effects" "true"
SET_PROP "system" "persist.sys.maxregner.sound.orb_morph" "true"

# UI effect mapping consumed by the Maxregner sound layer.
SET_PROP "system" "persist.sys.maxregner.sound.tick" "Maxregner_Tick.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.swoosh" "Maxregner_Swoosh.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.orb_morph" "Maxregner_OrbMorph.ogg"

LOG_STEP_OUT
