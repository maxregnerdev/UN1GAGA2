# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
#
# aiosd - UN1CA AIOS native AI runtime daemon
#
# System service that hosts the on-device Galaxy AI inferencing stack for
# Exynos 8895 hardware. Implements small quantized model inference with ARM
# NEON acceleration, an audio DSP pipeline for the Audio Eraser feature, and
# a binder-less socket RPC interface used by the AIOS framework extensions.

cmake_minimum_required(VERSION 3.18.1)
project(aiosd CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(aiosd
    src/aiosd.cpp
    src/neon_ops.cpp
    src/audio_dsp.cpp
    src/rpc_server.cpp
    src/config.cpp
)

target_compile_options(aiosd PRIVATE
    -fvisibility=hidden
    -ffunction-sections
    -fdata-sections
    $<$<CXX_COMPILER_ID:Clang>:-march=armv8-a+simd>
)

target_link_options(aiosd PRIVATE
    -Wl,--gc-sections
    -Wl,--exclude-libs,ALL
)
