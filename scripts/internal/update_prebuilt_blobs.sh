#!/usr/bin/env bash
# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

DEVICE=""
MODEL=""
CSC=""
IMEI=""
LATEST_FIRMWARE=""

# UPDATE_BLOBS
# Walks the prebuilt blobs directory for the configured device and refreshes
# every blob from the freshly downloaded/extracted firmware, splitting files
# larger than 50 MiB into .00/.01 chunks to match the existing on-disk layout.
UPDATE_BLOBS()
{
    local BLOBS
    local PREBUILTS_DIR="$SRC_DIR/prebuilts/samsung/$DEVICE"
    local FILE_PATH
    local CHUNK_SIZE=52428800

    BLOBS="$(_COLLECT_BLOBS_LIST "$PREBUILTS_DIR")"
    BLOBS="$(LC_ALL=C sort <<< "$BLOBS")"

    for i in $BLOBS; do
        if [[ "$i" == *.[0-9][0-9] ]]; then
            [[ "$i" == *".00" ]] || continue
            i="${i%.*}"
        fi
        FILE_PATH="$PREBUILTS_DIR/${i//system\/system\//system/}"

        if [ ! -f "$FW_DIR/${MODEL}_${CSC}/$i" ]; then
            LOGE "File not found: ${FW_DIR//$SRC_DIR\//}/${MODEL}_${CSC}/$i"
            exit 1
        fi

        LOG "- Updating prebuilts/samsung/$DEVICE/$i"

        if [ ! -L "$FW_DIR/${MODEL}_${CSC}/$i" ] && \
                [ "$(wc -c "$FW_DIR/${MODEL}_${CSC}/$i" | cut -d " " -f 1)" -gt "$CHUNK_SIZE" ]; then
            EVAL "rm \"$FILE_PATH.\"*" || exit 1
            EVAL "split -d -b $CHUNK_SIZE \"$FW_DIR/${MODEL}_${CSC}/$i\" \"$FILE_PATH.\"" || exit 1
        else
            EVAL "cp -a \"$FW_DIR/${MODEL}_${CSC}/$i\" \"$FILE_PATH\"" || exit 1
        fi
    done

    EVAL "cp -a \"$FW_DIR/${MODEL}_${CSC}/.extracted\" \"$PREBUILTS_DIR/.current\"" || exit 1
}

_COLLECT_BLOBS_LIST()
{
    local PREBUILTS_DIR="$1"
    local BLOBS=""
    local PART
    local SUB

    for PART in "system" "product" "vendor" "system_ext"; do
        if [ -d "$PREBUILTS_DIR/$PART" ]; then
            SUB="$(find "$PREBUILTS_DIR/$PART" ! -type d)"
            SUB="${SUB//$PREBUILTS_DIR\/$PART}"
            [ "$BLOBS" ] && BLOBS+=$'\n'
            BLOBS+="$PART$SUB"
        fi
    done

    BLOBS="${BLOBS//$PREBUILTS_DIR\//}"
    echo "$BLOBS"
}
# ]

if [[ "$#" != "2" ]]; then
    echo "Usage: update_prebuilt_blobs <device> <firmware>" >&2
    exit 1
fi

DEVICE="$1"
shift
if [ ! -d "$SRC_DIR/prebuilts/samsung/$DEVICE" ]; then
    LOGE "Folder not found: prebuilts/samsung/$DEVICE"
    exit 1
fi

PARSE_FIRMWARE_STRING "$1" || exit 1

LATEST_FIRMWARE="$(GET_LATEST_FIRMWARE "$MODEL" "$CSC")"
if [ ! "$LATEST_FIRMWARE" ]; then
    LOGE "Latest available firmware could not be fetched"
    exit 1
fi

LOG_STEP_IN true "Starting update_prebuilt_blobs for prebuilts/samsung/$DEVICE"
LOG "- Current firmware: $(cat "$SRC_DIR/prebuilts/samsung/$DEVICE/.current" 2> /dev/null)"
LOG "- Latest available firmware: $LATEST_FIRMWARE"

if [[ "$LATEST_FIRMWARE" == "$(cat "$SRC_DIR/prebuilts/samsung/$DEVICE/.current" 2> /dev/null)" ]]; then
    LOG_STEP_IN
    LOG "\033[0;33m! Nothing to do\033[0m"
    exit 0
fi

LOG_STEP_OUT

LOG_STEP_IN true "Downloading firmware"
"$SRC_DIR/scripts/download_fw.sh" --ignore-source --ignore-target "$MODEL/$CSC/${IMEI:=$SERIAL_NO}" || exit 1
LOG_STEP_OUT

LOG_STEP_IN true "Extracting firmware"
"$SRC_DIR/scripts/extract_fw.sh" --ignore-source --ignore-target "$MODEL/$CSC/${IMEI:=$SERIAL_NO}" || exit 1
LOG_STEP_OUT

LOG_STEP_IN true "Updating blobs"
UPDATE_BLOBS || exit 1

exit 0
