# AIOS Security & Privacy framework
#
# Hardware privacy controls, key attestation spoofing (TrickyStore), Play
# Integrity, Knox bypass stack and the application governance matrix.

LOG_STEP_IN "- Applying AIOS security & privacy framework"

# Hardware privacy controls: Quick Settings toggles that completely sever
# the camera, microphone and location feeds at the HAL level.
SET_PROP "system" "ro.aios.privacy.hardware_controls" "true"
SET_PROP "system" "persist.sys.aios.privacy.camera" "on"
SET_PROP "system" "persist.sys.aios.privacy.microphone" "on"
SET_PROP "system" "persist.sys.aios.privacy.location" "on"

# TrickyStore key attestation spoofing (requires a valid keybox file at
# /data/adb/tricky_store/keybox.xml).
SET_PROP "system" "ro.aios.security.keystore_attestation" "trickystore"

# Play Integrity Fix: Basic + Device integrity out of the box.
SET_PROP "system" "persist.sys.aios.security.pif" "basic,device"

# Knox bypass stack: Samsung Health, Secure Folder and Samsung Pass on
# unlocked bootloaders.
SET_PROP "system" "ro.aios.security.knox_bypass" "true"

# Application governance.
SET_PROP "system" "persist.sys.aios.security.hide_my_applist" "true"
SET_PROP "system" "persist.sys.aios.security.dev_options_hidden" "false"
SET_PROP "system" "persist.sys.aios.security.allow_downgrade" "true"
SET_PROP "system" "persist.sys.aios.security.allow_legacy_target_sdk" "true"
SET_PROP "system" "persist.sys.aios.security.secure_screenshot" "false"

# CSC extra enhancements: region-free call recording, Hiya spam protection,
# network speed meter and AltZLife profile switcher.
SET_PROP "system" "persist.sys.aios.csc.call_recording" "true"
SET_PROP "system" "persist.sys.aios.csc.hiya" "true"
SET_PROP "system" "persist.sys.aios.csc.net_speed_meter" "true"
SET_PROP "system" "persist.sys.aios.csc.altzlife" "true"

LOG_STEP_OUT
