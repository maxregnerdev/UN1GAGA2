# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later

cmake_minimum_required(VERSION 3.18.1)
project(erofs_hal CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(erofs_hal
    shim.cpp
)

target_compile_options(erofs_hal PRIVATE
    -fvisibility=hidden
    -ffunction-sections
    -fdata-sections
)

target_link_options(erofs_hal PRIVATE
    -Wl,--gc-sections
)
