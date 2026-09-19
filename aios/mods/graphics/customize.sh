# AIOS Graphics — Vulkan compositor
#
# Ships the custom-compiled Vulkan 1.2 graphics pipeline (aios_compositor)
# and enables the framework-level blur/toggle switches.

LOG_STEP_IN "- Applying AIOS graphics pipeline (aios_compositor)"

if [ -f "$TOOLS_DIR/bin/aios_compositor" ]; then
    LOG "- Installing aios_compositor binary"
    mkdir -p "$MODPATH/system/system/bin"
    cp "$TOOLS_DIR/bin/aios_compositor" "$MODPATH/system/system/bin/aios_compositor"
    chmod 755 "$MODPATH/system/system/bin/aios_compositor"
else
    LOGW "aios_compositor binary not found in tools dir; enabling framework toggles only"
fi

# Vulkan compositor toggles. On the S8 (dreamlte) the compositor replaces the
# legacy RenderEngine blur path; radius is tuned for 60 FPS on Mali-G71.
SET_PROP "system" "ro.aios.graphics.vulkan" "true"
SET_PROP "system" "ro.aios.graphics.vulkan.version" "1.2"
SET_PROP "system" "persist.sys.aios.graphics.live_blur" "true"
SET_PROP "system" "persist.sys.aios.graphics.blur_fps" "60"
SET_PROP "system" "persist.sys.aios.graphics.blur_radius" "16"

# Adaptive display drivers: color tone + simulated adaptive refresh rate.
SET_PROP "system" "persist.sys.aios.graphics.adaptive_tone" "true"
SET_PROP "system" "persist.sys.aios.graphics.adaptive_refresh" "true"

# Galaxy S25 asset ecosystem: wallpapers, sounds and adaptive iconography.
SET_PROP "system" "ro.aios.assets.s25" "true"

LOG_STEP_OUT
