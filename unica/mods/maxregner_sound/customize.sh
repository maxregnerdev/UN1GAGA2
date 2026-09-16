# Maxregner Sound Scheme v2
#
# Replaces the default Samsung/One UI sound set with the Maxregner v2 sound
# scheme. v2 adds layered spatial sound: separate layers for UI effects, the
# navigation orb and system feedback, plus secondary notification/ringtone/
# alarm variants. The scheme is applied system-wide through the ro.config.*
# sound properties so ringtones, notifications, alarms, the boot/power sound
# and UI effects all resolve to Maxregner assets.
#
# Audio binaries (.ogg) live alongside this script under
#   system/system/media/audio/{ui,notifications,ringtones,alarms}/
# Drop replacement assets into those folders; the build picks them up via the
# system/ tree addition performed by apply_modules.sh.
#
# Asset naming (all assets are referenced by the props below):
#   ui/        Maxregner_PowerOn.ogg      (boot / power on)
#   ui/        Maxregner_PowerOff.ogg     (shutdown)
#   ui/        Maxregner_Tick.ogg         (selection tick)
#   ui/        Maxregner_Swoosh.ogg       (transition)
#   ui/        Maxregner_OrbMorph.ogg     (orb morph, used by nav)
#   ui/        Maxregner_OrbRadial.ogg    (orb radial menu open)
#   ui/        Maxregner_OrbDock.ogg      (orb magnetic dock snap)
#   ui/        Maxregner_GlassTick.ogg    (glass UI tick)
#   ui/        Maxregner_Charge.ogg       (charging feedback)
#   ui/        Maxregner_Lock.ogg / Maxregner_Unlock.ogg (device lock/unlock)
#   notifications/ Maxregner_Notice.ogg / Maxregner_Pulse.ogg
#   ringtones/    Maxregner_Resonance.ogg / Maxregner_Echo.ogg
#   alarms/       Maxregner_Alarm.ogg / Maxregner_Horizon.ogg

LOG_STEP_IN "- Applying Maxregner sound scheme v2"

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

# Mark the Maxregner v2 sound scheme as the active theme and advertise it.
SET_PROP "system" "ro.maxregner.sound.scheme" "maxregner"
SET_PROP "system" "ro.maxregner.sound.enabled" "true"
SET_PROP "system" "ro.maxregner.sound.version" "2"

# UI effect mapping consumed by the Maxregner sound layer.
SET_PROP "system" "persist.sys.maxregner.sound.ui_effects" "true"
SET_PROP "system" "persist.sys.maxregner.sound.orb_morph" "true"
SET_PROP "system" "persist.sys.maxregner.sound.tick" "Maxregner_Tick.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.swoosh" "Maxregner_Swoosh.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.orb_morph" "Maxregner_OrbMorph.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.orb_radial" "Maxregner_OrbRadial.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.orb_dock" "Maxregner_OrbDock.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.glass_tick" "Maxregner_GlassTick.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.lock" "Maxregner_Lock.ogg"
SET_PROP "system" "persist.sys.maxregner.sound.unlock" "Maxregner_Unlock.ogg"

LOG_STEP_OUT
