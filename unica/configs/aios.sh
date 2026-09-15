# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
# AI OS v1.0 build configuration.
# Sourced by unica/configs/version.sh when AIOS_BUILD=true, overriding the
# UN1CA version/codename so the produced ROM identifies as AI OS while still
# being built by the UN1CA incremental patching pipeline.
# shellcheck disable=SC2034 # variables are consumed by version.sh under set -o allexport

AIOS_VERSION_MAJOR=1
AIOS_VERSION_MINOR=0
AIOS_VERSION_PATCH=0

# Override the UN1CA version + codename so every build artifact, prop and
# fingerprint reports AI OS instead of UN1CA.
VERSION_MAJOR="$AIOS_VERSION_MAJOR"
VERSION_MINOR="$AIOS_VERSION_MINOR"
VERSION_PATCH="$AIOS_VERSION_PATCH"
ROM_CODENAME="Orion"

unset AIOS_VERSION_MAJOR AIOS_VERSION_MINOR AIOS_VERSION_PATCH
