# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$SRC_DIR/scripts/utils/build_utils.sh" || return 1
# ]

# _DECODE_BUILD_VERSION <string>
# Extracts the OS major/year/month/incremental version segments from a Samsung build string.
_DECODE_BUILD_VERSION()
{
    local STRING="$1"

    STRING="$(cut -d "/" -f 1 -s <<< "$STRING")"

    # Samsung Android OS build version scheme works as follows (eg. A528BXXU1DWA4):
    # - A528B: Model number
    # - XX: Region (XX = EUR_OPEN)
    # - U: Firmware type (U = full update, S = security update)
    # - 1: Rollback protection bit
    # - D: Major OS version (D = 4th OS rollout)
    # - W: Year (W = 2023)
    # - A: Month (A = january)
    # - 4: Incremental version
    DECODE_MAJOR="${STRING:${#STRING}-4:1}"
    DECODE_YEAR="${STRING:${#STRING}-3:1}"
    DECODE_MONTH="${STRING:${#STRING}-2:1}"
    DECODE_INCREMENTAL="${STRING:${#STRING}-1:1}"
}

# COMPARE_SEC_BUILD_VERSION <string1> <string2>
# Returns whether or not `string1` build number is older than `string2`.
COMPARE_SEC_BUILD_VERSION()
{
    local STRING1="$1"
    local STRING2="$2"

    local DECODE_MAJOR
    local DECODE_YEAR
    local DECODE_MONTH
    local DECODE_INCREMENTAL
    local STRING1_MAJOR
    local STRING1_YEAR
    local STRING1_MONTH
    local STRING1_INCREMENTAL

    _DECODE_BUILD_VERSION "$STRING1"
    STRING1_MAJOR="$DECODE_MAJOR"
    STRING1_YEAR="$DECODE_YEAR"
    STRING1_MONTH="$DECODE_MONTH"
    STRING1_INCREMENTAL="$DECODE_INCREMENTAL"

    local STRING2_MAJOR
    local STRING2_YEAR
    local STRING2_MONTH
    local STRING2_INCREMENTAL

    _DECODE_BUILD_VERSION "$STRING2"
    STRING2_MAJOR="$DECODE_MAJOR"
    STRING2_YEAR="$DECODE_YEAR"
    STRING2_MONTH="$DECODE_MONTH"
    STRING2_INCREMENTAL="$DECODE_INCREMENTAL"

    [[ "$STRING1_MAJOR" > "$STRING2_MAJOR" ]] && return 0
    [[ "$STRING1_MAJOR" < "$STRING2_MAJOR" ]] && return 1
    [[ "$STRING1_YEAR" > "$STRING2_YEAR" ]] && return 0
    [[ "$STRING1_YEAR" < "$STRING2_YEAR" ]] && return 1
    [[ "$STRING1_MONTH" > "$STRING2_MONTH" ]] && return 0
    [[ "$STRING1_MONTH" < "$STRING2_MONTH" ]] && return 1
    [[ "$STRING1_INCREMENTAL" > "$STRING2_INCREMENTAL" ]] && return 0
    [[ "$STRING1_INCREMENTAL" < "$STRING2_INCREMENTAL" ]] && return 1

    return 0
}

# EXTRACT_FILE_FROM_TAR <tar> <file>
# Extract the desired file from the supplied tar archive.
EXTRACT_FILE_FROM_TAR()
{
    _CHECK_NON_EMPTY_PARAM "MODEL" "$MODEL" || return 1
    _CHECK_NON_EMPTY_PARAM "CSC" "$CSC" || return 1
    _CHECK_NON_EMPTY_PARAM "TAR" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1

    local TAR="$1"
    local FILE="$2"
    local OUT_DIR="$FW_DIR/${MODEL}_${CSC}"

    if [ ! -f "$TAR" ]; then
        LOGE "File not found: ${TAR//$SRC_DIR\//}"
        return 1
    fi

    rm -f "$OUT_DIR/$FILE" "$OUT_DIR/$FILE.ext4" "$OUT_DIR/$FILE.lz4"

    if FILE_EXISTS_IN_TAR "$TAR" "$FILE"; then
        LOG "- Extracting $FILE..."
        EVAL "tar xf \"$TAR\" -C \"$OUT_DIR\" \"$FILE\"" || return 1
    elif FILE_EXISTS_IN_TAR "$TAR" "$FILE.ext4"; then
        LOG "- Extracting $FILE.ext4..."
        EVAL "tar xf \"$TAR\" -C \"$OUT_DIR\" \"$FILE.ext4\"" || return 1
        EVAL "mv -f \"$OUT_DIR/$FILE.ext4\" \"$OUT_DIR/$FILE\"" || return 1
    elif FILE_EXISTS_IN_TAR "$TAR" "$FILE.lz4"; then
        LOG "- Extracting $FILE.lz4..."
        EVAL "tar xf \"$TAR\" -C \"$OUT_DIR\" \"$FILE.lz4\"" || return 1
        LOG "- Decompressing $FILE.lz4..."
        EVAL "lz4 -d --rm \"$OUT_DIR/$FILE.lz4\" \"$OUT_DIR/$FILE\"" || return 1
    fi

    return 0
}

# FILE_EXISTS_IN_TAR <tar> <file>
# Returns whether or not the desired file exists in the supplied tar archive.
FILE_EXISTS_IN_TAR()
{
    _CHECK_NON_EMPTY_PARAM "TAR" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1

    tar tf "$1" "$2" &> /dev/null
    return $?
}

# GET_LATEST_FIRMWARE <model> <csc>
# Returns the latest available firmware for the supplied model & CSC in the following format: PDA/CSC/MODEM
GET_LATEST_FIRMWARE()
{
    _CHECK_NON_EMPTY_PARAM "MODEL" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "CSC" "$2" || return 1

    curl -s --retry 3 -m 3 "https://fota-cloud-dn.ospserver.net/firmware/$2/$1/version.xml" \
        | perl -nE 'say $1 if /<latest[^>]*>(.*?)<\/latest>/'
}

# PARSE_FIRMWARE_STRING <string>
# Parses the supplied string and stores each value in MODEL/CSC/IMEI/SERIAL_NO variables.
# - The supplied string must be in the following format: <MODEL>/<CSC>/<IMEI/SN>
# - IMEI/SN that matches the given model is required to download the firmware from FUS
PARSE_FIRMWARE_STRING()
{
    local STRING="$1"

    if [ ! "$STRING" ]; then
        LOGE "Firmware value cannot be empty"
        return 1
    fi

    MODEL="$(cut -d "/" -f 1 -s <<< "$STRING")"
    if [ ! "$MODEL" ]; then
        LOGE "No device model value found in \"$STRING\""
        return 1
    fi

    CSC="$(cut -d "/" -f 2 -s <<< "$STRING")"
    if [ ! "$CSC" ]; then
        LOGE "No CSC value found in \"$STRING\""
        return 1
    elif [[ "${#CSC}" != "3" ]]; then
        LOGE "CSC not valid in \"$STRING\": $CSC"
        return 1
    fi

    local THIRD
    THIRD="$(cut -d "/" -f 3 -s <<< "$STRING")"
    if [ ! "$THIRD" ]; then
        LOGE "No IMEI/SN value found in \"$STRING\""
        return 1
    elif [[ "${#THIRD}" == "11" ]] && [[ "$THIRD" == "R"* ]]; then
        # shellcheck disable=SC2034
        SERIAL_NO="$THIRD"
    elif [[ "${#THIRD}" -ge "8" ]] && [[ "${#THIRD}" -le "15" ]] && [[ "$THIRD" =~ ^[+-]?[0-9]+$ ]]; then
        # shellcheck disable=SC2034
        # Allow uncomplete IMEIs as samloader can generate them by providing the first 8 numbers (TAC)
        IMEI="$THIRD"
    else
        LOGE "No valid IMEI/SN in \"$STRING\": $THIRD"
        return 1
    fi

    return 0
}

# UNSPARSE_IMAGE <file> [output]
# Unsparse the supplied file, a different output path can be provided optionally.
UNSPARSE_IMAGE()
{
    _CHECK_NON_EMPTY_PARAM "FILE" "$1" || exit 1

    local FILE="$1"
    local OUTPUT_PATH="$2"
    local REPLACE=false

    if [ ! -f "$FILE" ]; then
        LOGE "File not found: ${FILE//$SRC_DIR\//}"
        return 1
    fi

    if ! IS_SPARSE_IMAGE "$FILE"; then
        LOGW "Not a Android sparse image: ${FILE//$SRC_DIR\//}"
        return 0
    fi

    if [ ! "$OUTPUT_PATH" ]; then
        OUTPUT_PATH="$(dirname "$FILE")/unsparse_$(basename "$FILE")"
        REPLACE=true
    fi

    LOG "- Unsparsing $(basename "$FILE")..."

    EVAL "simg2img \"$FILE\" \"$OUTPUT_PATH\"" || return 1
    if $REPLACE; then
        mv -f "$OUTPUT_PATH" "$FILE"
    fi

    return 0
}
