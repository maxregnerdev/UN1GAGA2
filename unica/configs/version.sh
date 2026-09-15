# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# Only the below variable(s) need to be changed!
VERSION_MAJOR=1
VERSION_MINOR=1
VERSION_PATCH=0

# AI OS build override: when AIOS_BUILD=true, source the AI OS config to
# rebrand the build as AI OS v0.1 (codename Aether) instead of UN1CA.
if [ "$AIOS_BUILD" = "true" ] && [ -f "$SRC_DIR/unica/configs/aios.sh" ]; then
    # shellcheck disable=SC1091
    source "$SRC_DIR/unica/configs/aios.sh"
fi

# The below variables will be generated automatically
#
# Version name
ROM_VERSION="${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}"
# Codename
# shellcheck disable=SC2034 # sourced by scripts/internal/gen_config_file.sh and unica/patches/__props/customize.sh
ROM_CODENAME="Poseidon"
# Append "+" to version name if commits have been added since the last tag
LATEST_TAG="$(git describe --tags --abbrev=0 2> /dev/null)"
if [ "$LATEST_TAG" ]; then
    if [[ "$(git rev-list --count "$LATEST_TAG...HEAD" 2> /dev/null)" =~ 0*[1-9][0-9]* ]]; then
        ROM_VERSION+="+"
    fi
fi
# Append current commit hash to version name
ROM_VERSION+="-$(git rev-parse --short HEAD 2> /dev/null || echo "null")"
# Append "-dirty" to version name if uncommitted changes are detected
if [ "$(git --no-optional-locks status -uno --porcelain 2> /dev/null)" ]; then
    ROM_VERSION+="-dirty"
fi
