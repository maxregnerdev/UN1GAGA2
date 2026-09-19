# AIOS Samsung DeX HAL
#
# Enables the rewritten DeX hardware HAL: wired desktop output via the
# USB-C DisplayPort alternate mode plus wireless screen mirroring.

LOG_STEP_IN "- Applying AIOS DeX HAL"

if [ -f "$TOOLS_DIR/bin/erofs_hal" ]; then
    LOG "- Installing DeX HAL shim"
    mkdir -p "$MODPATH/system/system/bin"
    cp "$TOOLS_DIR/bin/erofs_hal" "$MODPATH/system/system/bin/hw/aios.dex-hal" 2>/dev/null || \
        { mkdir -p "$MODPATH/system/system/bin/hw"; \
          cp "$TOOLS_DIR/bin/erofs_hal" "$MODPATH/system/system/bin/hw/aios.dex-hal"; }
fi

SET_PROP "system" "ro.aios.dex.enabled" "true"
SET_PROP "system" "persist.sys.aios.dex.displayport" "true"
SET_PROP "system" "persist.sys.aios.dex.wireless" "true"

LOG_STEP_OUT
