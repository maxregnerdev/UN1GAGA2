#!/usr/bin/env bash
# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
# [
# Builds the UN1CA AIOS native C++ system services (aiosd AI runtime daemon,
# Vulkan compositor, EROFS HAL shim) as aarch64 binaries using the NDK-style
# toolchain selected by build_dependencies.sh.

source "$SRC_DIR/scripts/utils/log_utils.sh" || exit 1

PRINT_USAGE()
{
    echo "Usage: build_native_services [--arm64|--host]" >&2
}

BUILD_NATIVE_SERVICE()
{
    local NAME="$1"
    local DIR="$SRC_DIR/native/$NAME"
    local BUILD_DIR="$OUT_DIR/native/$NAME"

    if [ ! -f "$DIR/CMakeLists.txt" ]; then
        LOGE "File not found: native/$NAME/CMakeLists.txt"
        return 1
    fi

    LOG_STEP_IN true "- Building $NAME"
    mkdir -p "$BUILD_DIR"
    # shellcheck disable=SC2086
    cmake -S "$DIR" -B "$BUILD_DIR" $NATIVE_CMAKE_FLAGS || return 1
    cmake --build "$BUILD_DIR" --parallel "$(nproc)" || return 1

    if [ -f "$BUILD_DIR/$NAME" ]; then
        mkdir -p "$TOOLS_DIR/bin"
        cp "$BUILD_DIR/$NAME" "$TOOLS_DIR/bin/$NAME"
    fi
    LOG_STEP_OUT
    return 0
}

# ]
NATIVE_CMAKE_FLAGS=""
PREPARE_SCRIPT()
{
    while [[ "$#" != 0 ]]; do
        if [[ "$1" == "--arm64" ]] || [[ "$1" == "-a" ]]; then
            NATIVE_CMAKE_FLAGS+="-DCMAKE_SYSTEM_NAME=Android "
            NATIVE_CMAKE_FLAGS+="-DCMAKE_SYSTEM_PROCESSOR=aarch64 "
            NATIVE_CMAKE_FLAGS+="-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a "
        elif [[ "$1" == "--host" ]] || [[ "$1" == "-h" ]] && [[ "$1" != "--help" ]]; then
            NATIVE_CMAKE_FLAGS+="-DCMAKE_SYSTEM_NAME=Linux "
            NATIVE_CMAKE_FLAGS+="-DCMAKE_SYSTEM_PROCESSOR=$(uname -m) "
        elif [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
            PRINT_USAGE
            exit 0
        else
            LOGE "Unknown option: $1"
            PRINT_USAGE
            exit 1
        fi
        shift
    done
    if [ ! "$NATIVE_CMAKE_FLAGS" ]; then
        NATIVE_CMAKE_FLAGS="-DCMAKE_SYSTEM_NAME=Android "
        NATIVE_CMAKE_FLAGS+="-DCMAKE_SYSTEM_PROCESSOR=aarch64 "
        NATIVE_CMAKE_FLAGS+="-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a "
    fi
}

PREPARE_SCRIPT "$@"

for SERVICE in aiosd aios_compositor erofs_hal; do
    BUILD_NATIVE_SERVICE "$SERVICE" || exit 1
done

exit 0
