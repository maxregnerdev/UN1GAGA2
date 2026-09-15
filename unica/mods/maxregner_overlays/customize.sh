# Maxregner System Overlays
#
# Builds the Maxregner Runtime Resource Overlay (RRO) APKs from source
# (prebuilts/maxregner/rro/*) and ships the compiled, signed, zipaligned
# overlays as real .apk files into /product/overlay so the OverlayManagerService
# applies them on boot. This is the in-ROM equivalent of the overlay half of
# the standalone Maxregner Magisk zip (scripts/build_maxregner_zip.sh); both
# use the same shared compile/sign helper (scripts/utils/rro_utils.sh).
#
# Requires the android-tools build tools (aapt2, zipalign, apksigner, keytool,
# java) which are on PATH during the in-ROM make_rom build.

# shellcheck disable=SC2034
SKIPUNZIP=1

# shellcheck disable=SC1091
source "$SRC_DIR/scripts/utils/rro_utils.sh" || exit 1

LOG_STEP_IN "- Compiling Maxregner RRO overlays"

# Stage the compiled overlays under a local product/ tree so ADD_TO_WORK_DIR
# (product partition) copies them verbatim into the work-dir /product partition
# and registers the correct fs_config / file_context entries.
STAGE_DIR="$OUT_DIR/maxregner_overlays/$TARGET_CODENAME/stage"
RRO_OUT="$STAGE_DIR/product/overlay"
COMPILE_MAXREGNER_RROS "$RRO_OUT" "$OUT_DIR/maxregner_overlays/keystore" || exit 1

# Add each compiled overlay APK into the /product partition.
for ov in "${MAXREGNER_RRO_OVERLAYS[@]}"; do
    ADD_TO_WORK_DIR "$STAGE_DIR" "product" "overlay/${ov}.apk" 0 0 644 \
        "u:object_r:system_file:s0" || exit 1
done

LOG_STEP_OUT
