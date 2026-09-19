# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
#
# aios_compositor - UN1CA AIOS Vulkan 1.2 hardware compositor service
#
# Renders the System UI surface stack with real-time GPU blur effects using
# Vulkan compute pipelines, replacing the legacy Skia/RenderEngine path on
# Mali-G71 hardware.

cmake_minimum_required(VERSION 3.18.1)
project(aios_compositor CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(aios_compositor
    src/aios_compositor.cpp
    src/vulkan_context.cpp
    src/blur_pipeline.cpp
)

target_compile_options(aios_compositor PRIVATE
    -fvisibility=hidden
    -ffunction-sections
    -fdata-sections
)

target_link_options(aios_compositor PRIVATE
    -Wl,--gc-sections
)
