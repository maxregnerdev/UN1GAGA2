# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
# shellcheck disable=SC1007,SC2164
# https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/envsetup.sh#18
_GET_SRC_DIR()
{
    local TOPFILE="unica/configs/version.sh"
    if [ -n "$SRC_DIR" ] && [ -f "$SRC_DIR/$TOPFILE" ]; then
        (cd "$SRC_DIR"; PWD= /bin/pwd)
    else
        if [ -f "$TOPFILE" ]; then
            PWD= /bin/pwd
        else
            local HERE="$PWD"
            local T=
            while [ \( ! \( -f "$TOPFILE" \) \) ] && [ \( "$PWD" != "/" \) ]; do
                \cd ..
                T="$(PWD= /bin/pwd -P)"
            done
            \cd "$HERE"
            if [ -f "$T/$TOPFILE" ]; then
                echo "$T"
            fi
        fi
    fi
}

_PRINT_AVAILABLE_TARGETS()
{
    echo "Available devices:" >&2
    printf '%s\n' "${TARGETS[@]}" >&2
}

_PRINT_USAGE()
{
    echo "Usage: source buildenv.sh [--debug] <target>" >&2
    _PRINT_AVAILABLE_TARGETS
}

_PARSE_BUILD_OPTIONS()
{
    while [[ "$1" == "-"* ]]; do
        case "$1" in
            "--debug")
                export DEBUG=true
                ;;
            "--help"|"-h")
                _PRINT_USAGE
                return 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                _PRINT_USAGE
                return 1
                ;;
        esac
        shift
    done

    if [ "$#" -ne 1 ]; then
        echo "No target specified. Please choose from the available devices below:"
        select SELECTED_TARGET in "${TARGETS[@]}"; do
            if [ -n "$SELECTED_TARGET" ]; then
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
    else
        SELECTED_TARGET="$1"
    fi

    return 0
}

_VALIDATE_TARGET()
{
    if [ ! -d "$SRC_DIR/target/$SELECTED_TARGET" ]; then
        echo "\"$SELECTED_TARGET\" is not a valid device." >&2
        _PRINT_USAGE
        return 1
    fi
    return 0
}

_EXPORT_BUILD_DIRECTORIES()
{
    export OUT_DIR="$SRC_DIR/out"
    export ODIN_DIR="$OUT_DIR/odin"
    export FW_DIR="$OUT_DIR/fw"
    export TOOLS_DIR="$OUT_DIR/tools"
    if [[ ":$PATH:" != *":$TOOLS_DIR/bin:"* ]]; then
        export PATH="$TOOLS_DIR/bin:$PATH"
    fi
}

_EXPORT_TARGET_DIRECTORIES()
{
    export APKTOOL_DIR="$OUT_DIR/target/$SELECTED_TARGET/apktool"
    export WORK_DIR="$OUT_DIR/target/$SELECTED_TARGET/work_dir"
    export TMP_DIR="$OUT_DIR/target/$SELECTED_TARGET/tmp"
    mkdir -p "$OUT_DIR/target/$SELECTED_TARGET"
}

_DISCOVER_TARGETS()
{
    TARGETS=()
    while IFS= read -r t; do
        TARGETS+=("$t")
    done < <(find "$SRC_DIR/target" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
}

_LOAD_TARGET_CONFIG()
{
    # shellcheck disable=SC2046
    [ -f "$OUT_DIR/config.sh" ] && unset $(sed "/Automatically/d" "$OUT_DIR/config.sh" | cut -d "=" -f 1)
    "$SRC_DIR/scripts/internal/gen_config_file.sh" "$SELECTED_TARGET" || return 1
    set -o allexport; source "$OUT_DIR/config.sh"; set +o allexport
}

_PRINT_BUILD_HEADER()
{
    echo "=============================="
    sed "/Automatically/d" "$OUT_DIR/config.sh"
    echo "=============================="
}

# https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/envsetup.sh#806
croot()
{
    if [ -d "$SRC_DIR" ]; then
        if [ "$1" ]; then
            cd "$SRC_DIR/$1"
        else
            cd "$SRC_DIR"
        fi
    else
        echo "Couldn't locate the top of the tree. Try setting SRC_DIR."
        return 1
    fi
}

_DISCOVER_SCRIPTS()
{
    local CMDS=()
    while IFS= read -r f; do
        CMDS+=("$f")
    done < <(find "$SRC_DIR/scripts" -maxdepth 1 ! -type d -printf '%f\n' | sort | sed "s/\.sh//")
    printf '%s\n' "${CMDS[@]}"
}

run_cmd()
{
    local CMD="$1"

    if [ -x "$SRC_DIR/scripts/$CMD.sh" ]; then
        shift
        mkdir -p "$(dirname "$WORK_DIR")"
        (set -o pipefail; "$SRC_DIR/scripts/$CMD.sh" "$@" |& tee \
            >(sed -r -e "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" -e "/#/d" > "$(dirname "$WORK_DIR")/$CMD-$(date +%Y%m%d_%H%M%S).log"))
        return $?
    else
        if [ "$CMD" ]; then
            if [[ "$CMD" == "--help" ]] || [[ "$CMD" == "-h" ]]; then
                echo "Available cmds:" >&2
                for c in $(_DISCOVER_SCRIPTS); do
                    echo -e '\n\033[1;37m'"$c:"'\033[0m'
                    "$SRC_DIR/scripts/$c.sh" --help
                done
                return 0
            else
                echo -e '\033[0;31m'"\"$CMD\" is not a valid cmd."'\\033[0m' >&2
            fi
        fi

        echo "Available cmds:" >&2
        _DISCOVER_SCRIPTS >&2
        return 1
    fi
}

alias unica=run_cmd
# ]

SRC_DIR="$(_GET_SRC_DIR)"
if [ ! "$SRC_DIR" ]; then
    echo "Couldn't locate the top of the tree. Always source buildenv.sh from the root of the tree." >&2
    return 1
fi

unset -f _GET_SRC_DIR

export DEBUG=false
export SRC_DIR
_EXPORT_BUILD_DIRECTORIES

_DISCOVER_TARGETS

_PARSE_BUILD_OPTIONS "$@" || return 1
_VALIDATE_TARGET || return 1

unset -f _PRINT_USAGE _PRINT_AVAILABLE_TARGETS

_EXPORT_TARGET_DIRECTORIES
_LOAD_TARGET_CONFIG || return 1

unset TARGETS SELECTED_TARGET

_PRINT_BUILD_HEADER

unset -f _EXPORT_BUILD_DIRECTORIES _EXPORT_TARGET_DIRECTORIES _DISCOVER_TARGETS \
    _LOAD_TARGET_CONFIG _PRINT_BUILD_HEADER _PARSE_BUILD_OPTIONS _VALIDATE_TARGET \
    _DISCOVER_SCRIPTS

return 0
