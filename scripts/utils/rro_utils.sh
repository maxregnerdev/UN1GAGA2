#!/usr/bin/env bash
# Copyright (c) 2026 maxregner
# SPDX-License-Identifier: GPL-3.0-or-later
# [
# Shared Maxregner RRO (Runtime Resource Overlay) compilation helper.
# Used by both the standalone Maxregner Magisk zip builder
# (scripts/build_maxregner_zip.sh) and the in-ROM build mod
# (unica/mods/maxregner_overlays) so the same signed overlay APKs are
# produced in both delivery paths.
#
# Requires aapt2, zipalign, apksigner, keytool and java on PATH.
#
# COMPILE_MAXREGNER_RROS <out_dir> <keystore_dir>
#   Compiles every overlay declared in MAXREGNER_RRO_OVERLAYS (sourced from
#   prebuilts/maxregner/rro/<name>/) into a signed, zipaligned APK named
#   <name>.apk under <out_dir>. Reuses a keystore (generated once) and an
#   android.jar framework jar (fetched once) stored under <keystore_dir>.
#   Returns non-zero on any compile/link/sign failure.

MAXREGNER_RRO_SRC="$SRC_DIR/prebuilts/maxregner/rro"

MAXREGNER_RRO_OVERLAYS=(
    "maxregner_ui_overlay"
    "maxregner_nav_overlay"
    "maxregner_extras_overlay"
    "maxregner_statusbar_overlay"
    "maxregner_launcher_overlay"
    "maxregner_icons_overlay"
    "maxregner_quicksettings_overlay"
    "maxregner_notifications_overlay"
    "maxregner_framework_overlay"
)

# Resolve the Android SDK / build-tools toolchain onto PATH for the RRO
# compile/sign steps. The standalone Maxregner zip job already prepends the
# system build-tools dir to $GITHUB_PATH, but the in-ROM ROM-build job only
# has $TOOLS_DIR/bin (android-tools build), which ships zipalign but not
# aapt2/apksigner. Locate aapt2/apksigner across the standard locations and
# prepend the containing dir to PATH so both delivery paths can compile.
_MAXREGNER_RRO_RESOLVE_TOOLCHAIN() {
    if command -v aapt2 >/dev/null 2>&1 && command -v apksigner >/dev/null 2>&1; then
        return 0
    fi
    local _dir _bt
    local _candidates=(
        "$TOOLS_DIR/bin"
        "$ANDROID_HOME/build-tools"/*
        "$ANDROID_SDK_HOME/build-tools"/*
        "$ANDROID_SDK/build-tools"/*
        /usr/lib/android-sdk/build-tools/*
        /usr/local/lib/android/sdk/build-tools/*
        /opt/android-sdk/build-tools/*
    )
    for _bt in "${_candidates[@]}"; do
        for _dir in $_bt; do
            [ -d "$_dir" ] || continue
            if [ -x "$_dir/aapt2" ] && [ -x "$_dir/apksigner" ]; then
                case ":$PATH:" in
                    *":$_dir:"*) ;;
                    *) PATH="$_dir:$PATH"; export PATH ;;
                esac
                return 0
            fi
        done
    done
    LOGE "aapt2/apksigner not found on PATH or in any Android SDK build-tools dir"
    return 1
}

_ENSURE_RRO_KEYSTORE(){
    local KS_DIR="$1"
    local KS="$KS_DIR/maxregner.keystore"
    if [ ! -f "$KS" ]; then
        LOG "- Generating Maxregner signing key"
        mkdir -p "$KS_DIR"
        keytool -genkeypair -v -keystore "$KS" -alias maxregner \
            -keyalg RSA -keysize 2048 -validity 10000 \
            -storepass maxregner -keypass maxregner \
            -dname "CN=maxregner, O=maxregner, C=US" >/dev/null 2>&1 || {
            LOGE "Failed to generate signing key"
            return 1
        }
    fi
    printf '%s' "$KS"
}

_ENSURE_RRO_FRAMEWORK_JAR(){
    local KS_DIR="$1"
    local ANDJ="$KS_DIR/android_29.jar"
    if [ ! -f "$ANDJ" ]; then
        LOG "- Fetching Android 10 framework jar for RRO compilation"
        python3 - "$ANDJ" <<'PYEOF' || { LOGE "Failed to fetch android.jar framework"; return 1; }
import sys, urllib.request
url = "https://repo1.maven.org/maven2/org/robolectric/android-all/10-robolectric-5803371/android-all-10-robolectric-5803371.jar"
try:
    req = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
    data = urllib.request.urlopen(req, timeout=120).read()
    if len(data) < 1000000:
        raise RuntimeError("download too small")
    open(sys.argv[1], "wb").write(data)
    sys.stderr.write("framework jar ok\n")
except Exception as e:
    sys.stderr.write("download failed: %s\n" % e)
    sys.exit(1)
PYEOF
    fi
    printf '%s' "$ANDJ"
}

COMPILE_MAXREGNER_RROS(){
    if [ -z "$1" ]; then LOGE "OUT_DIR must not be empty"; return 1; fi
    if [ -z "$2" ]; then LOGE "KEYSTORE_DIR must not be empty"; return 1; fi
    _MAXREGNER_RRO_RESOLVE_TOOLCHAIN || return 1
    local OUT_DIR="$1"
    local KS_DIR="$2"
    local KS ANDJ
    KS="$(_ENSURE_RRO_KEYSTORE "$KS_DIR")" || return 1
    ANDJ="$(_ENSURE_RRO_FRAMEWORK_JAR "$KS_DIR")" || return 1
    mkdir -p "$OUT_DIR"
    local ov src compiled linked aligned
    for ov in "${MAXREGNER_RRO_OVERLAYS[@]}"; do
        LOG "- Compiling RRO $ov"
        src="$MAXREGNER_RRO_SRC/$ov"
        if [ ! -d "$src/res" ] || [ ! -f "$src/AndroidManifest/AndroidManifest.xml" ]; then
            LOGE "RRO source not found: $src"
            return 1
        fi
        compiled="$KS_DIR/${ov}-compiled.zip"
        linked="$KS_DIR/${ov}-unsigned.apk"
        aligned="$KS_DIR/${ov}-aligned.apk"
        aapt2 compile --dir "$src/res" -o "$compiled" || { LOGE "aapt2 compile failed: $ov"; return 1; }
        aapt2 link -o "$linked" --manifest "$src/AndroidManifest/AndroidManifest.xml" \
            -I "$ANDJ" "$compiled" || { LOGE "aapt2 link failed: $ov"; return 1; }
        zipalign -p -f 4 "$linked" "$aligned" || { LOGE "zipalign failed: $ov"; return 1; }
        apksigner sign --ks "$KS" --ks-pass pass:maxregner --key-pass pass:maxregner \
            --out "$OUT_DIR/$ov.apk" "$aligned" || { LOGE "apksigner failed: $ov"; return 1; }
        rm -f "$compiled" "$linked" "$aligned" "$OUT_DIR/$ov.apk.idsig"
    done
    # Verify each compiled overlay is a valid overlay APK (sanity guard).
    for ov in "${MAXREGNER_RRO_OVERLAYS[@]}"; do
        if ! aapt2 dump badging "$OUT_DIR/$ov.apk" 2>/dev/null | grep -q "^overlay:"; then
            LOGE "Built overlay is not a valid RRO: $ov"
            return 1
        fi
    done
    return 0
}
# ]
