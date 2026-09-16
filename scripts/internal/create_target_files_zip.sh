#!/usr/bin/env bash
# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$SRC_DIR/scripts/utils/install_utils.sh" || exit 1

if ! $BUILD_FLASHABLE_ZIP; then
    trap 'rm -rf "$TMP_DIR"' EXIT
fi

# GET_SUPER_GROUP_SIZE
# Returns the size in bytes of the target super partition group.
# https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/build_super_image.py#72
GET_SUPER_GROUP_SIZE()
{
    local GROUP_NAME="$TARGET_SUPER_GROUP_NAME"
    GROUP_NAME="$(tr "[:lower:]" "[:upper:]" <<< "$TARGET_SUPER_GROUP_NAME")"

    local VAR="TARGET_${GROUP_NAME}_SIZE"

    _CHECK_NON_EMPTY_PARAM "$VAR" "${!VAR}" || exit 1

    echo "${!VAR}"
}

# BUILD_SUPER_EMPTY
# Builds an unsparse super_empty.img via lpmake containing every partition
# image currently present in $TMP_DIR.
# https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/build_super_image.py#72
BUILD_SUPER_EMPTY()
{
    local CMD

    CMD="lpmake"
    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/build_super_image.py#75
    CMD+=" --metadata-size \"65536\""
    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/core/config.mk#1033
    CMD+=" --super-name \"super\""
    # https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/tools/releasetools/build_super_image.py#85
    CMD+=" --metadata-slots \"2\""
    CMD+=" --device \"super:$TARGET_SUPER_PARTITION_SIZE\""
    CMD+=" --group \"$TARGET_SUPER_GROUP_NAME:$(GET_SUPER_GROUP_SIZE)\""
    for p in $PARTITIONS_LIST; do
        if [ -f "$TMP_DIR/$p.img" ]; then
            CMD+=" --partition \"$p:readonly:0:$TARGET_SUPER_GROUP_NAME\""
        fi
    done
    CMD+=" --output \"$TMP_DIR/unsparse_super_empty.img\""

    EVAL "$CMD" || exit 1
}

# GENERATE_BUILD_INFO
# Writes the build_info.txt descriptor used by the OTA packaging scripts.
GENERATE_BUILD_INFO()
{
    local BUILD_INFO_FILE="$TMP_DIR/build_info.txt"

    local SOURCE_FIRMWARE_PATH
    local TARGET_FIRMWARE_PATH
    local SOURCE_FINGERPRINT
    local TARGET_FINGERPRINT

    SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
    TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

    SOURCE_FINGERPRINT="$(_COMPUTE_FINGERPRINT "$FW_DIR/$SOURCE_FIRMWARE_PATH")"
    TARGET_FINGERPRINT="$(_COMPUTE_FINGERPRINT "$FW_DIR/$TARGET_FIRMWARE_PATH")"

    {
        echo -n "device="
        [ "$(GET_PROP "system" "ro.unica.device")" ] && GET_PROP "system" "ro.unica.device" || echo "$TARGET_CODENAME"
        [ "$TARGET_ASSERT_MODEL" ] && echo "model=${TARGET_ASSERT_MODEL//:/;}"
        echo "name=$TARGET_NAME"
        echo -n "version="
        [ "$(GET_PROP "system" "ro.unica.version")" ] && GET_PROP "system" "ro.unica.version" || echo "$ROM_VERSION"
        echo -n "timestamp="
        [ "$(GET_PROP "system" "ro.unica.timestamp")" ] && GET_PROP "system" "ro.unica.timestamp" || echo "$ROM_BUILD_TIMESTAMP"
        echo "os_version=$(GET_PROP "system" "ro.build.version.release")"
        echo "oneui_version=$(GET_PROP "system" "ro.build.version.oneui")"
        echo "build_incremental=$(GET_PROP "system" "ro.build.version.incremental")"
        echo "build_date=$(GET_PROP "system" "ro.build.date.utc")"
        echo "security_patch=$(GET_PROP "system" "ro.build.version.security_patch")"
        echo "source_fingerprint=$SOURCE_FINGERPRINT"
        echo "target_fingerprint=$TARGET_FINGERPRINT"
        echo "use_dynamic_partitions=$TARGET_USE_DYNAMIC_PARTITIONS"
        if $TARGET_USE_DYNAMIC_PARTITIONS; then
            echo "super_partition_size=$TARGET_SUPER_PARTITION_SIZE"
            echo "super_partition_group=$TARGET_SUPER_GROUP_NAME"
            echo "super_${TARGET_SUPER_GROUP_NAME}_group_size=$(GET_SUPER_GROUP_SIZE)"
        fi
    } > "$BUILD_INFO_FILE"
}

_COMPUTE_FINGERPRINT()
{
    local FW_PATH="$1"
    local SYSTEM_PROP="$FW_PATH/system/system/build.prop"
    local VENDOR_PROP="$FW_PATH/vendor/build.prop"

    local FINGERPRINT
    FINGERPRINT="$(GET_PROP "$SYSTEM_PROP" "ro.system.build.fingerprint")"
    FINGERPRINT="${FINGERPRINT//$(GET_PROP "$SYSTEM_PROP" "ro.build.product")/$(GET_PROP "$VENDOR_PROP" "ro.product.vendor.device")}"
    echo "$FINGERPRINT"
}
# ]

if [ "$#" != "1" ]; then
    echo "Usage: create_target_files_zip <output>" >&2
    exit 1
fi

OUTPUT_FILE="$1"

if $TARGET_USE_DYNAMIC_PARTITIONS; then
    LOG "- Building unsparse_super_empty.img"
    BUILD_SUPER_EMPTY
fi

if [ -d "$WORK_DIR/kernel" ]; then
    KERNEL_BINS="boot.img dt.img dtbo.img init_boot.img vendor_boot.img"

    for f in $KERNEL_BINS; do
        [ ! -f "$WORK_DIR/kernel/$f" ] && continue

        LOG_STEP_IN "- Copying $f"
        EVAL "cp -a \"$WORK_DIR/kernel/$f\" \"$TMP_DIR/$f\"" || exit 1
        if ! $TARGET_DISABLE_AVB_SIGNING; then
            SIGN_IMAGE_WITH_AVB "$TMP_DIR/$f" || exit 1
        fi
        LOG_STEP_OUT
    done
fi

LOG "- Generating build_info.txt"
GENERATE_BUILD_INFO

LOG "- Creating zip"
rm -f "$OUTPUT_FILE"
EVAL "cd \"$TMP_DIR\" && 7z a -tzip -mx=3 -mmt=$(nproc) -mtc=off -mtm=off \"$OUTPUT_FILE\" -r *" || exit 1

exit 0
