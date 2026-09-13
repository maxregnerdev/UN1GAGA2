#!/usr/bin/env bash
# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Builds the standalone Maxregner TWRP flashable zip for a target device.
# The zip installs on top of an existing UN1CA install and activates the
# Maxregner navigation, sound scheme, UI design system and extras/perf profiles
# without modifying the read-only erofs partitions:
#   - ships the Maxregner file tree to /data/maxregner/system
#   - installs a Magisk/KernelSU boot service that setprop's the Maxregner props
#     and bind-mounts the bundled files over the read-only partition paths
#
# Usage: build_maxregner_zip.sh [--output <file>] [--target <codename>]
# Defaults: target=dreamlte, output=$OUT_DIR/Maxregner_<version>_<codename>.zip

# [
source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

OUTPUT_FILE=""
TARGET_CODENAME_ARG=""

PREPARE_SCRIPT()
{
    while [[ "$#" != 0 ]]; do
        if [[ "$1" == "--output" ]] || [[ "$1" == "-o" ]]; then
            shift
            OUTPUT_FILE="$1"
        elif [[ "$1" == "--target" ]] || [[ "$1" == "-t" ]]; then
            shift
            TARGET_CODENAME_ARG="$1"
        elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
            PRINT_USAGE
            exit 0
        else
            LOGE "Unknown option: $1"
            PRINT_USAGE
            exit 1
        fi
        shift
    done

    [ -z "$TARGET_CODENAME_ARG" ] && TARGET_CODENAME_ARG="dreamlte"
}

PRINT_USAGE()
{
    echo "Usage: build_maxregner_zip [options]" >&2
    echo " -o, --output <file> : Output zip path" >&2
    echo " -t, --target <name> : Target codename (default: dreamlte)" >&2
    echo " -h, --help          : Show this help" >&2
}
# ]

PREPARE_SCRIPT "$@"

MAXREGNER_SRC="$SRC_DIR/prebuilts/maxregner/zip"
MODS_DIR="$SRC_DIR/unica/mods"
STAGE_DIR="$OUT_DIR/maxregner/$TARGET_CODENAME_ARG/stage"

if [ ! -d "$MAXREGNER_SRC/META-INF" ]; then
    LOGE "Maxregner zip scaffold not found: $MAXREGNER_SRC"
    exit 1
fi

if [ ! -d "$MODS_DIR" ]; then
    LOGE "Mods directory not found: $MODS_DIR"
    exit 1
fi

LOG_STEP_IN true "Building Maxregner flashable zip for $TARGET_CODENAME_ARG"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

# 1. Copy the TWRP update-binary + updater-script scaffold.
mkdir -p "$STAGE_DIR/META-INF/com/google/android"
cp -a "$MAXREGNER_SRC/META-INF/com/google/android/update-binary" \
      "$STAGE_DIR/META-INF/com/google/android/update-binary"
cp -a "$MAXREGNER_SRC/META-INF/com/google/android/updater-script" \
      "$STAGE_DIR/META-INF/com/google/android/updater-script"
chmod 0755 "$STAGE_DIR/META-INF/com/google/android/update-binary"

# 2. Stage the runtime payload root: maxregner/
PAYLOAD="$STAGE_DIR/maxregner"
mkdir -p "$PAYLOAD"

# Boot service.
mkdir -p "$PAYLOAD/service"
cp -a "$MAXREGNER_SRC/maxregner/service/maxregner_boot.sh" "$PAYLOAD/service/maxregner_boot.sh"
chmod 0755 "$PAYLOAD/service/maxregner_boot.sh"

# Aggregated props + bind-mount map (shipped verbatim).
cp -a "$MAXREGNER_SRC/maxregner/maxregner.props" "$PAYLOAD/maxregner.props"
cp -a "$MAXREGNER_SRC/maxregner/file_map.txt" "$PAYLOAD/file_map.txt"

# 3. Assemble the Maxregner file tree from the mod system/ trees into
#    maxregner/system/system (mirrors the live partition layout 1:1 for the
#    bind-mounts: the runtime path is /data/maxregner/system + <src>, where
#    <src> begins with /system/..., so the payload must contain system/system/...).
SYSTEM_ROOT="$PAYLOAD/system/system"
mkdir -p "$SYSTEM_ROOT"

MAXREGNER_MODS=(
    "maxregner_nav"
    "maxregner_sound"
    "maxregner_ui"
    "maxregner_extras"
    "maxregner_perf"
)

for mod in "${MAXREGNER_MODS[@]}"; do
    MOD_SYS="$MODS_DIR/$mod/system/system"
    if [ ! -d "$MOD_SYS" ]; then
        LOGW "Maxregner mod has no system tree: $mod"
        continue
    fi
    LOG "- Merging $mod system tree"
    # shellcheck disable=SC2012
    ( cd "$MOD_SYS" && find . -type f ) | while IFS= read -r f; do
        f="${f#./}"
        mkdir -p "$SYSTEM_ROOT/${f%/*}"
        cp -a "$MOD_SYS/$f" "$SYSTEM_ROOT/$f"
    done
done

# 4. Verify the staged file map resolves to staged files (build-time guard).
#    The boot service resolves each src as MAXREGNER_DIR/system + src, so mirror
#    that here against the staged payload root.
map_failed=false
while IFS='	' read -r src dst; do
    case "$src" in ''|\#*) continue ;; esac
    [ -n "$dst" ] || continue
    if [ ! -e "$PAYLOAD/system$src" ]; then
        LOGW "file_map entry not staged: $src"
        map_failed=true
    fi
done < "$PAYLOAD/file_map.txt"
if $map_failed; then
    LOGW "Some file_map entries are not present in the staged payload (skipped at runtime)"
fi

# 5. Write build_info.txt so the zip self-describes.
{
    echo "name=Maxregner"
    echo "target=$TARGET_CODENAME_ARG"
    echo "version=$ROM_VERSION"
    echo "codename=$ROM_CODENAME"
    echo "timestamp=$(date +%s)"
    echo "built_by=maxregner"
} > "$PAYLOAD/build_info.txt"

# 6. Zip it.
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="$OUT_DIR/Maxregner_${ROM_VERSION}_${TARGET_CODENAME_ARG}.zip"
fi
mkdir -p "${OUTPUT_FILE%/*}"
rm -f "$OUTPUT_FILE"

( cd "$STAGE_DIR" && zip -r -q "$OUTPUT_FILE" . ) || {
    LOGE "Failed to create zip: $OUTPUT_FILE"
    exit 1
}

LOG_STEP_OUT
LOG "Maxregner zip: ${OUTPUT_FILE//$SRC_DIR\//}"

exit 0
