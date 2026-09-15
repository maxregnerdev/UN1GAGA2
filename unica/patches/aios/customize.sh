# shellcheck disable=SC2034
SKIPUNZIP=1

AIOS_VERSION="1.0"
AIOS_CODENAME="Orion"

# Property identifying the AI OS version
SET_PROP "system" "ro.aios.version" "$AIOS_VERSION"
EVAL "echo \"ro.aios.version u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# Property identifying the AI OS codename
SET_PROP "system" "ro.aios.codename" "$AIOS_CODENAME"
EVAL "echo \"ro.aios.codename u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# Property identifying the AI OS build time
SET_PROP "system" "ro.aios.timestamp" "$ROM_BUILD_TIMESTAMP"
EVAL "echo \"ro.aios.timestamp u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# Property identifying the device AI OS is being built for
SET_PROP "system" "ro.aios.device" "$TARGET_CODENAME"
EVAL "echo \"ro.aios.device u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# Property identifying the AI OS base (UN1CA incremental patching)
SET_PROP "system" "ro.aios.base" "unica"
EVAL "echo \"ro.aios.base u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# Property identifying the AI OS core subsystem
SET_PROP "system" "ro.aios.core" "maxregner"
EVAL "echo \"ro.aios.core u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# AI OS build fingerprint
# aios/<ro.aios.device>:<AIOS_VERSION>/<ro.aios.timestamp>:<user/userdebug>/<release/test>-keys
AIOS_FINGERPRINT="aios/${TARGET_CODENAME}:"
AIOS_FINGERPRINT+="${AIOS_VERSION}/${ROM_BUILD_TIMESTAMP}:"
if $DEBUG; then
    AIOS_FINGERPRINT+="userdebug/"
else
    AIOS_FINGERPRINT+="user/"
fi
if $ROM_IS_OFFICIAL; then
    AIOS_FINGERPRINT+="release-keys"
else
    AIOS_FINGERPRINT+="test-keys"
fi
SET_PROP "system" "ro.aios.fingerprint" "$AIOS_FINGERPRINT"
EVAL "echo \"ro.aios.fingerprint u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
unset AIOS_FINGERPRINT

# Rebrand the OS in the floating feature config so Samsung system apps
# display the AI OS product name instead of the donor device name.
if [ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SETTINGS_CONFIG_BRAND_NAME")" ]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SETTINGS_CONFIG_BRAND_NAME" "AI OS"
fi

# Rebrand the build display id so the OS identifies as AI OS in Settings.
SET_PROP "system" "ro.build.display.id" "AIOS-1.0-${TARGET_CODENAME}"
SET_PROP "system" "ro.product.system.name" "aios"

# Register the AI core as a known product feature so the framework exposes
# the AI subsystem availability to apps querying system features.
if [ ! "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_AI_CONFIG_CORE_VERSION")" ]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_AI_CONFIG_CORE_VERSION" "1.0"
fi

unset AIOS_VERSION AIOS_CODENAME
