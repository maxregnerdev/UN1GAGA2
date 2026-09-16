# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$SRC_DIR/scripts/utils/common_utils.sh"
# ]

_SMALI_OPERATION_IS_VALID()
{
    local OPERATION="$1"
    case "$OPERATION" in
        "null"|"remove"|"replace"|"replaceall"|"return"|"strip")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

_SMALI_METHOD_EXISTS()
{
    local FILE_PATH="$1"
    local SMALI="$2"
    local METHOD="$3"

    grep "^\.method.*" "$FILE_PATH/$SMALI" | grep -q -F -- "$METHOD" "$FILE_PATH/$SMALI"
}

_PRINT_SMALI_MATCHES()
{
    local MATCHES="$1"
    local PREFIX="$2"

    echo -e "\n\033[0;31m${PREFIX}:" >&2
    echo -e -n "$(head -n 10 <<< "${MATCHES//$FILE_PATH\//$PREFIX - }")" >&2
    if [ "$(wc -l <<< "$MATCHES")" -gt 10 ]; then
        echo -e -n "$PREFIX - ...and other $(($(wc -l <<< "$MATCHES") - 10)) matches" >&2
    fi
    echo -e "\033[0m" >&2
}

_AWK_STRIP_METHOD()
{
    awk -v FN="$METHOD" '
        BEGIN { inside = 0; skip = 0 }
        /^\.method/ && index($0, FN) {
            inside = 1
            next
        }
        inside && /^\.end method/ {
            inside = 0
            skip = 1
            next
        }
        inside { next }
        {
            if (skip) {
                skip = 0
                next
            }
            print
        }
    ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
        mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"
}

_AWK_NULLIFY_METHOD()
{
    local LOC="$1"
    local RET="$2"

    awk -v FN="$METHOD" -v LOC="$LOC" -v RET="$RET" '
        BEGIN { inside = 0 }
        /^\.method/ && index($0, FN) {
            print
            print "    " LOC
            print "    "
            print "    " RET
            inside = 1
            next
        }
        inside && /^\.end method/ {
            print
            inside = 0
            next
        }
        inside { next }
        { print }
    ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
        mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"
}

_AWK_RETURN_VALUE()
{
    local LOC="$1"
    local VAL="$2"
    local RET="$3"

    awk -v FN="$METHOD" -v LOC="$LOC" -v VAL="$VAL" -v RET="$RET" '
        BEGIN { inside = 0 }
        /^\.method/ && index($0, FN) {
            print
            print "    " LOC
            print ""
            print "    " VAL
            print ""
            print "    " RET
            inside = 1
            next
        }
        inside && /^\.end method/ {
            print
            inside = 0
            next
        }
        inside { next }
        { print }
    ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
        mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"
}

_AWK_REPLACE_IN_METHOD()
{
    local VAL="$1"
    local REP="$2"

    awk -v FN="$METHOD" -v STR="$VAL" -v REP="$REP" '
        BEGIN { inside = 0; isline = (index(REP, "\n") > 0) }
        /^\.method/ && index($0, FN) { inside = 1 }
        inside {
            if (isline) {
                if (index($0, STR)) {
                    gsub(/\\n/, "\n", REP)
                    print REP
                    next
                }
            } else if ($0 ~ /^[[:space:]]*const-string(\/jumbo)?/) {
                sub("\"" STR "\"", "\"" REP "\"")
            } else {
                line = $0
                gsub(/^[ \t]+|[ \t]+$/, "", line)

                if (line == STR) {
                    match($0, /^[ \t]+/)
                    indent = substr($0, RSTART, RLENGTH)
                    $0 = indent REP
                }
            }
        }
        inside && /^\.end method/ { inside = 0 }
        { print }
    ' "$FILE_PATH/$SMALI" > "$FILE_PATH/$SMALI.tmp" && \
        mv "$FILE_PATH/$SMALI.tmp" "$FILE_PATH/$SMALI"
}

_RESOLVE_RETURN_REGISTER()
{
    local METHOD="$1"
    local FILE_PATH="$2"

    local REG="p0"
    local LOC=".locals 0"
    if [[ "$(grep "^\.method.*" "$FILE_PATH/$SMALI" | \
                grep -F -- "$METHOD" "$FILE_PATH/$SMALI")" == *" static "* ]] && \
            [[ "$METHOD" == *"()"* ]]; then
        REG="v0"
        LOC=".locals 1"
    fi

    RESOLVED_REG="$REG"
    RESOLVED_LOC="$LOC"
}

_RESOLVE_RETURN_INSTRUCTION()
{
    local RET_TYPE="$1"
    local VALUE="$2"
    local REG="$3"

    local RET
    RET="${RET_TYPE#*)}"

    if [[ "$RET" == "V" ]]; then
        LOGE "Cannot change return value of void method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
        return 1
    elif [[ "$RET" == "Ljava/lang/String;" ]]; then
        RESOLVED_RET="return-object $REG"
        RESOLVED_VALUE="\"$VALUE\""
    elif [[ "$RET" =~ ^\[*[ZBCSIJFD]$ ]]; then
        if [[ "$RET" == "Z" ]]; then
            if [[ "$VALUE" == "true" ]]; then
                VALUE="0x1"
            elif [[ "$VALUE" == "false" ]]; then
                VALUE="0x0"
            fi

            if [[ "$VALUE" != "0x0" ]] && [[ "$VALUE" != "0x1" ]]; then
                LOGE "Cannot use a constant value for method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
                return 1
            fi
        fi

        if [[ "$VALUE" =~ ^-?[0-9]+$ ]]; then
            VALUE="0x$(printf "%x" "$VALUE")"
        fi

        if [[ "$VALUE" =~ ^\".*\"$ ]]; then
            LOGE "Cannot use a string value for method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
            return 1
        fi

        if [[ "$RET" == "J" ]]; then
            RESOLVED_RET="return-wide $REG"
        else
            RESOLVED_RET="return $REG"
        fi
        RESOLVED_VALUE="$VALUE"
    else
        if [[ "$VALUE" == "null" ]]; then
            VALUE="0x0"
        fi

        if [[ "$VALUE" != "0x0" ]]; then
            LOGE "Cannot use a constant value for method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
            return 1
        fi

        RESOLVED_RET="return-object $REG"
        RESOLVED_VALUE="$VALUE"
    fi
}

_RESOLVE_CONSTANT_INSTRUCTION()
{
    local VALUE="$1"
    local REG="$2"
    local RET_TYPE="$3"

    local RET="${RET_TYPE#*)}"
    local hex
    local num

    if [[ "$VALUE" =~ ^-?0x[0-9a-fA-F]+$ ]]; then
        if [[ "$VALUE" == "-"* ]]; then
            hex="${VALUE#-0x}"
            num="$((-16#$hex))"
        else
            hex="${VALUE#0x}"
            num="$((16#$hex))"
        fi
        if [[ "$RET" == "J" ]]; then
            RESOLVED_CONST="const-wide/16 $REG, $VALUE"
        elif [ "$num" -gt "-8" ] && [ "$num" -lt "8" ]; then
            RESOLVED_CONST="const/4 $REG, $VALUE"
        else
            RESOLVED_CONST="const/16 $REG, $VALUE"
        fi
    elif [[ "$VALUE" =~ ^\".*\"$ ]]; then
        RESOLVED_CONST="const-string $REG, $VALUE"
    else
        LOGE "Return value for method \"$METHOD\" in /$PARTITION/$FILE/$SMALI not valid: \"$VALUE\""
        return 1
    fi
}

_VERIFY_SMALI_CHANGED()
{
    local BEFORE="$1"
    local AFTER
    AFTER="$(sha1sum "$FILE_PATH/$SMALI")"

    if [[ "$BEFORE" == "$AFTER" ]]; then
        LOGE "Failed to $2 method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
        return 1
    fi
    return 0
}

# SMALI_PATCH <partition> <apk/jar> <smali> <operation> [method] [value] [replacement]
# Dynamically patches the provided smali file with the supplied arguments.
#
# Usage:
# - null <method>: Deletes the contents of supplied method in the provided smali file
# - remove: Deletes the provided smali file entirely
# - replace <method> <value> <replacement>: Replaces the occurence of the supplied string in the provided method
# - replaceall <value> <replacement>: Replaces all the occurences of the supplied string in the whole smali file
# - return <method> <value>: Patches the supplied method in order to return the desired value
# - strip <method>: Deletes the supplied method in the provided smali file
SMALI_PATCH()
{
    _CHECK_NON_EMPTY_PARAM "PARTITION" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1
    _CHECK_NON_EMPTY_PARAM "SMALI" "$3" || return 1
    _CHECK_NON_EMPTY_PARAM "OPERATION" "$4" || return 1

    local PARTITION="$1"
    local FILE="$2"
    local SMALI="$3"
    local OPERATION="$4"

    if ! IS_VALID_PARTITION_NAME "$PARTITION"; then
        LOGE "\"$PARTITION\" is not a valid partition name"
        return 1
    fi

    while [[ "${FILE:0:1}" == "/" ]]; do
        FILE="${FILE:1}"
    done

    DECODE_APK "$PARTITION" "$FILE" || return 1

    if ! _SMALI_OPERATION_IS_VALID "$OPERATION"; then
        LOGE "Operation not valid: \"$OPERATION\""
        return 1
    fi

    if [[ "$OPERATION" == "replaceall" ]]; then
        _CHECK_NON_EMPTY_PARAM "VALUE" "$5" || return 1
        local VALUE="$5"
        local REPLACEMENT="$6"
    elif [[ "$OPERATION" != "remove" ]]; then
        _CHECK_NON_EMPTY_PARAM "METHOD" "$5" || return 1
        local METHOD="$5"

        if ! [[ "$METHOD" =~ ^[A-Za-z0-9\$\<\-].*\(.*\).* ]]; then
            LOGE "Method name not valid: \"$METHOD\""
            return 1
        fi
    fi

    if [[ "$OPERATION" == "return" ]]; then
        _CHECK_NON_EMPTY_PARAM "VALUE" "$6" || return 1
        local VALUE="$6"
    fi

    if [[ "$OPERATION" == "replace" ]]; then
        _CHECK_NON_EMPTY_PARAM "VALUE" "$6" || return 1
        local VALUE="$6"
        local REPLACEMENT="$7"
    fi

    local FILE_PATH="$APKTOOL_DIR/$PARTITION/${FILE//system\//}"

    # Check if provided smali exists
    if [ ! -f "$FILE_PATH/$SMALI" ]; then
        LOGE "Smali not found: \"/$PARTITION/$FILE/$SMALI\""

        local MATCHES
        MATCHES="$(find "$FILE_PATH" -type f -name "*${SMALI##*/}")"

        if [ "$MATCHES" ]; then
            _PRINT_SMALI_MATCHES "$MATCHES" "Possible matches?"
        fi

        return 1
    elif [[ "$OPERATION" == "remove" ]]; then
        local USED
        USED="$(find "$FILE_PATH" ! -path "*$SMALI" -type f -exec grep -r -n -- "$(cut -d "." -f "1" <<< "${SMALI#*/}");" {} \+ || true)"
        USED="$(cut -d ":" -f 1-2 <<< "$USED")"

        if [ "$USED" ]; then
            LOGE "Cannot remove \"$SMALI\" from /$PARTITION/$FILE as it is used elsewhere"
            _PRINT_SMALI_MATCHES "$USED" "Matches"
            return 1
        fi

        LOG "- Removing \"$SMALI\" from /$PARTITION/$FILE"
        EVAL "LC_ALL=C rm \"$FILE_PATH/${SMALI//\$/\\$}\"" || return 1
        return 0
    fi

    # Check if provided method is method and exists inside smali
    if ! _SMALI_METHOD_EXISTS "$FILE_PATH" "$SMALI" "$METHOD"; then
        LOGE "Method \"$METHOD\" not found in /$PARTITION/$FILE/$SMALI"

        local MATCHES
        MATCHES="$(grep -r "^\.method.*$METHOD" "$FILE_PATH")"

        if [ "$MATCHES" ]; then
            _PRINT_SMALI_MATCHES "$MATCHES" "Possible matches?"
        fi

        return 1
    fi

    local BEFORE
    BEFORE="$(sha1sum "$FILE_PATH/$SMALI")"

    if [[ "$OPERATION" == "strip" ]]; then
        local USED
        USED="$(grep -r -n -- "invoke.*$(basename "$SMALI" | cut -d "." -f "1");" "$FILE_PATH")"
        USED="$(grep -F "$METHOD" <<< "$USED" | cut -d ":" -f 1-2)"

        if [ "$USED" ]; then
            LOGE "Cannot strip method \"$METHOD\" in /$PARTITION/$FILE/$SMALI as it is used elsewhere"
            _PRINT_SMALI_MATCHES "$USED" "Matches"
            return 1
        fi

        LOG "- Stripping method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
        _AWK_STRIP_METHOD
        _VERIFY_SMALI_CHANGED "$BEFORE" "strip" || return 1

    elif [[ "$OPERATION" == "null" ]]; then
        local RET
        local LOC=".locals 0"

        RET="${METHOD#*)}"
        if [[ "$RET" != "V" ]]; then
            LOGE "Cannot nullify non-void method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
            return 1
        else
            RET="return-void"
        fi

        LOG "- Nullifying method \"$METHOD\" in /$PARTITION/$FILE/$SMALI"
        _AWK_NULLIFY_METHOD "$LOC" "$RET"
        _VERIFY_SMALI_CHANGED "$BEFORE" "nullify" || return 1

    elif [[ "$OPERATION" == "return" ]]; then
        _RESOLVE_RETURN_REGISTER "$METHOD" "$FILE_PATH"
        local REG="$RESOLVED_REG"
        local LOC="$RESOLVED_LOC"

        _RESOLVE_RETURN_INSTRUCTION "$METHOD" "$VALUE" "$REG" || return 1
        local RET_INSTR="$RESOLVED_RET"
        local RET_VALUE="$RESOLVED_VALUE"

        _RESOLVE_CONSTANT_INSTRUCTION "$RET_VALUE" "$REG" "$METHOD" || return 1
        local CONST_INSTR="$RESOLVED_CONST"

        LOG "- Replacing return value of method \"$METHOD\" in /$PARTITION/$FILE/$SMALI to \"$CONST_INSTR\""
        _AWK_RETURN_VALUE "$LOC" "$CONST_INSTR" "$RET_INSTR"
        _VERIFY_SMALI_CHANGED "$BEFORE" "replace return value of" || return 1

    elif [[ "$OPERATION" == "replace" ]]; then
        LOG "- Replacing value \"$VALUE\" of method \"$METHOD\" in /$PARTITION/$FILE/$SMALI with \"$REPLACEMENT\""
        _AWK_REPLACE_IN_METHOD "$VALUE" "$REPLACEMENT"
        _VERIFY_SMALI_CHANGED "$BEFORE" "replace value of" || return 1

    elif [[ "$OPERATION" == "replaceall" ]]; then
        LOG "- Replacing all occurrences of \"$VALUE\" with \"$REPLACEMENT\" in /$PARTITION/$FILE/$SMALI"
        EVAL "sed -i \"s|$VALUE|$REPLACEMENT|g\" \"$FILE_PATH/${SMALI//\$/\\$}\"" || return 1
        _VERIFY_SMALI_CHANGED "$BEFORE" "replace all occurrences of" || return 1
    fi

    return 0
}
