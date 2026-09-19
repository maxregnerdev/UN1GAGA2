# AIOS AI Runtime (aiosd)
#
# Ships the re-engineered native C++ inferencing daemon (ARM NEON accelerated)
# and registers the full on-device Galaxy AI feature matrix with the
# framework. All inference runs locally; no cloud dependency.

LOG_STEP_IN "- Applying AIOS AI runtime (aiosd)"

if [ -f "$TOOLS_DIR/bin/aiosd" ]; then
    LOG "- Installing aiosd binary"
    mkdir -p "$MODPATH/system/system/bin"
    cp "$TOOLS_DIR/bin/aiosd" "$MODPATH/system/system/bin/aiosd"
    chmod 755 "$MODPATH/system/system/bin/aiosd"
else
    LOGW "aiosd binary not found in tools dir; installing service config only"
fi

# Daemon registration: starts on late-init, before the framework.
mkdir -p "$MODPATH/system/system/etc/init"
cat > "$MODPATH/system/system/etc/init/aiosd.rc" <<'EOF'
service aiosd /system/bin/aiosd
    class late_start
    user system
    group system
    socket aiosd seqpacket 660 system system
    oneshot

on late-init
    start aiosd
EOF

# Advertise the on-device Galaxy AI feature matrix.
SET_PROP "system" "ro.aios.ai.enabled" "true"
SET_PROP "system" "persist.sys.aios.ai.stack" "native"
for FEATURE in audio_eraser browsing_assist call_assist drawing_assist \
               interpreter note_assist now_brief photo_assist \
               semantic_search transcript_assist writing_assist; do
    SET_PROP "system" "persist.sys.aios.ai.feature.$FEATURE" "true"
done

LOG_STEP_OUT
