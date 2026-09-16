# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
_GET_CALLER_INFO()
{
    local SRC_FILE=""
    local LINE_NO=""
    local FUNC=""

    if [[ "${FUNCNAME[2]}" != "main" ]]; then
        FUNC="${FUNCNAME[2]}"
        SRC_FILE="${BASH_SOURCE[3]//$SRC_DIR//}"
        LINE_NO="${BASH_LINENO[2]}"
    else
        FUNC="${FUNCNAME[1]}"
        SRC_FILE="${BASH_SOURCE[2]//$SRC_DIR//}"
        LINE_NO="${BASH_LINENO[1]}"
    fi

    echo -n "("
    [ "$SRC_FILE" ] && echo -n "${SRC_FILE}:"
    [ "$LINE_NO" ] && echo -n "${LINE_NO}:"
    echo -n "${FUNC}) "
}

_FORMAT_INDENT()
{
    local INDENT="${INDENT_LEVEL:=0}"
    printf "%*s%s" "$INDENT" "" "$1"
}

# LOG <message>
# Prints a log message in the build output.
LOG()
{
    echo -e "$(_FORMAT_INDENT "$1")"
}

# LOGE <message>
# Prints an error log message in the build output.
LOGE()
{
    local RED="\033[0;31m"
    local RESET="\033[0m"

    echo -e "${RED}$(_GET_CALLER_INFO)${1}${RESET}" >&2
}

# LOGW <message>
# Prints a warning log message in the build output.
LOGW()
{
    local YELLOW="\033[0;33m"
    local RESET="\033[0m"

    echo -e "${YELLOW}$(_GET_CALLER_INFO)${1}${RESET}" >&2
}

# LOG_STEP_IN <bold> <message>
# Increments the output indentation, additionally prints a log message if supplied.
LOG_STEP_IN()
{
    local BOLD=""
    local RESET="\033[0m"

    if [[ "$1" == "true" ]]; then
        BOLD="\033[1;37m"
        shift
    fi

    if [ "$1" ]; then
        LOG "${BOLD}${1}${RESET}"
    fi

    local INDENT="${INDENT_LEVEL:=0}"
    export INDENT_LEVEL="$((INDENT + 2))"
}

# LOG_STEP_OUT
# Reduces the output indentation.
LOG_STEP_OUT()
{
    local INDENT="${INDENT_LEVEL:=0}"
    if [ "$INDENT_LEVEL" -gt 0 ]; then
        export INDENT_LEVEL=$((INDENT - 2))
    fi
}
# ]
