#!/usr/bin/env bash
# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Builds the standalone Maxregner Magisk module (flashable zip) for a target
# device. The module installs on top of an existing UN1CA install and activates
# the Maxregner navigation, sound scheme, UI design system, extras and
# performance/security profiles without modifying the read-only erofs partitions:
#   - compiles real RRO overlay APKs from source and ships them under
#     system/product/overlay/, which Magisk mounts systemlessly over the RO
#     partition (no custom bind-mount script needed)
#   - post-fs-data.sh sets every Maxregner prop via resetprop (overrides
#     read-only build.prop without writing the partition)
#   - service.sh enables the RRO overlays via `cmd overlay`
#   - ships real .ogg sound + .ttf font binary assets under system/media and
#     system/product/fonts
#
# Usage: build_maxregner_zip.sh [--output <file>] [--target <codename>]
# Defaults: target=dreamlte, output=$OUT_DIR/Maxregner_<version>_<codename>.zip

# [
# This is a lightweight standalone builder: it only needs the logging helpers
# and a few core utilities, so it sources log_utils directly instead of
# build_utils.sh (which would trigger the full android-tools toolchain build).
source "$SRC_DIR/scripts/utils/log_utils.sh" || exit 1

for _d in find cp mkdir rm chmod zip aapt2 zipalign apksigner keytool java; do
    if ! type "$_d" &> /dev/null; then
        LOGE "Required dependency not found: $_d"
        exit 1
    fi
done
unset _d

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

MODULE_SRC="$SRC_DIR/prebuilts/maxregner/module"
RRO_SRC="$SRC_DIR/prebuilts/maxregner/rro"
STAGE_DIR="$OUT_DIR/maxregner/$TARGET_CODENAME_ARG/stage"
KEYSTORE_DIR="$OUT_DIR/maxregner/keystore"

if [ ! -d "$MODULE_SRC" ]; then
    LOGE "Maxregner module scaffold not found: $MODULE_SRC"
    exit 1
fi

LOG_STEP_IN true "Building Maxregner Magisk module for $TARGET_CODENAME_ARG"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

# 1. Stage the Magisk module root files.
cp -a "$MODULE_SRC/module.prop" "$STAGE_DIR/module.prop"
cp -a "$MODULE_SRC/post-fs-data.sh" "$STAGE_DIR/post-fs-data.sh"
cp -a "$MODULE_SRC/service.sh" "$STAGE_DIR/service.sh"
cp -a "$MODULE_SRC/maxregner.props" "$STAGE_DIR/maxregner.props"
chmod 0755 "$STAGE_DIR/post-fs-data.sh" "$STAGE_DIR/service.sh"

# 2. Stage the module system/ tree (config JSONs, init rc, sound/font assets,
#    overlay config.xml). These are mounted systemlessly by Magisk.
mkdir -p "$STAGE_DIR/system"
# shellcheck disable=SC2012
( cd "$MODULE_SRC/system" && find . -type f ) | while IFS= read -r f; do
    f="${f#./}"
    mkdir -p "$STAGE_DIR/system/${f%/*}"
    cp -a "$MODULE_SRC/system/$f" "$STAGE_DIR/system/$f"
done

# 3. Compile the RRO overlay APKs from source.
#    aapt2 compile -> link -> zipalign -> apksigner sign -> module
#    system/product/overlay/<name>.apk (Magisk mounts these over the RO
#    partition; the OverlayManagerService applies them on boot via service.sh).
OVERLAY_DIR="$STAGE_DIR/system/product/overlay"
mkdir -p "$OVERLAY_DIR"

# Ensure a signing keystore exists (generated once, reused).
mkdir -p "$KEYSTORE_DIR"
KS="$KEYSTORE_DIR/maxregner.keystore"
if [ ! -f "$KS" ]; then
    LOG "- Generating Maxregner signing key"
    keytool -genkeypair -v -keystore "$KS" -alias maxregner \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass maxregner -keypass maxregner \
        -dname "CN=maxregner, O=maxregner, C=US" >/dev/null 2>&1 || {
        LOGE "Failed to generate signing key"
        exit 1
    }
fi

# Ensure an android.jar framework (-I) is available for aapt2 link.
ANDJ="$KEYSTORE_DIR/android_29.jar"
if [ ! -f "$ANDJ" ]; then
    LOG "- Fetching Android 10 framework jar for RRO compilation"
    python3 - "$ANDJ" <<'PYEOF' || { LOGE "Failed to fetch android.jar framework"; exit 1; }
import sys, urllib.request
url = "https://repo1.maven.org/maven2/org/robolectric/android-all/10-robolectric-5803371/android-all-10-robolectric-5803371.jar"
try:
    req = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
    data = urllib.request.urlopen(req, timeout=120).read()
    if len(data) < 1000000:
        raise RuntimeError("download too small")
    open(sys.argv[1], "wb").write(data)
    print("framework jar ok")
except Exception as e:
    sys.stderr.write("download failed: %s\n" % e)
    sys.exit(1)
PYEOF
fi

RRO_OVERLAYS=(
    "maxregner_ui_overlay"
    "maxregner_nav_overlay"
    "maxregner_extras_overlay"
)
for ov in "${RRO_OVERLAYS[@]}"; do
    LOG "- Compiling RRO $ov"
    src="$RRO_SRC/$ov"
    [ -d "$src/res" ] || { LOGE "RRO source not found: $src"; exit 1; }
    compiled="$STAGE_DIR/${ov}-compiled.zip"
    linked="$STAGE_DIR/${ov}-unsigned.apk"
    aligned="$STAGE_DIR/${ov}-aligned.apk"
    aapt2 compile --dir "$src/res" -o "$compiled" || { LOGE "aapt2 compile failed: $ov"; exit 1; }
    aapt2 link -o "$linked" --manifest "$src/AndroidManifest/AndroidManifest.xml" \
        -I "$ANDJ" "$compiled" || { LOGE "aapt2 link failed: $ov"; exit 1; }
    zipalign -p -f 4 "$linked" "$aligned" || { LOGE "zipalign failed: $ov"; exit 1; }
    apksigner sign --ks "$KS" --ks-pass pass:maxregner --key-pass pass:maxregner \
        --out "$OVERLAY_DIR/$ov.apk" "$aligned" || { LOGE "apksigner failed: $ov"; exit 1; }
    # apksigner v4 writes a sidecar .idsig; it is not needed for an installed overlay.
    rm -f "$compiled" "$linked" "$aligned" "$OVERLAY_DIR/$ov.apk.idsig"
done

# 4. Verify each compiled overlay is a valid overlay APK (sanity guard).
for ov in "${RRO_OVERLAYS[@]}"; do
    if ! aapt2 dump badging "$OVERLAY_DIR/$ov.apk" 2>/dev/null | grep -q "^overlay:"; then
        LOGE "Built overlay is not a valid RRO: $ov"
        exit 1
    fi
done

# 5. Write build_info.txt so the module self-describes.
{
    echo "name=Maxregner"
    echo "target=$TARGET_CODENAME_ARG"
    echo "version=$ROM_VERSION"
    echo "codename=$ROM_CODENAME"
    echo "timestamp=$(date +%s)"
    echo "built_by=maxregner"
} > "$STAGE_DIR/build_info.txt"

# 6. Zip the module (Magisk module zip: module.prop at the root).
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
LOG "Maxregner module: ${OUTPUT_FILE//$SRC_DIR\//}"

exit 0
