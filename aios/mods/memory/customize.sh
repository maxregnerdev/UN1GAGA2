# AIOS Memory — custom ZSTD zRAM allocator
#
# Configures the ZRAM swap device with the ZSTD compression algorithm, a
# 2.5GB pool and real-time compaction. Sized for the 4GB Exynos 8895 RAM
# subsystem.

LOG_STEP_IN "- Applying AIOS memory subsystem (ZSTD zRAM)"

ZRAM_SIZE="${AIOS_ZRAM_SIZE_BYTES:-2684354560}"
ZRAM_ALG="${AIOS_ZRAM_COMP_ALGORITHM:-zstd}"
ZRAM_DEV="/sys/block/zram0"

mkdir -p "$MODPATH/system/system/etc/init"
cat > "$MODPATH/system/system/etc/init/aios_zram.rc" <<EOF
on post-fs
    write $ZRAM_DEV/comp_algorithm "$ZRAM_ALG"
    write $ZRAM_DEV/disksize "$ZRAM_SIZE"
    mkswap /dev/block/zram0
    swapon /dev/block/zram0

on property:sys.aios.compact=1
    write /proc/sys/vm/compact_memory 1
    setprop sys.aios.compact 0
EOF

SET_PROP "system" "ro.aios.memory.zram" "true"
SET_PROP "system" "ro.aios.memory.zram.algorithm" "$ZRAM_ALG"
SET_PROP "system" "ro.aios.memory.zram.size" "$ZRAM_SIZE"
SET_PROP "system" "persist.sys.aios.memory.compaction" "realtime"

LOG_STEP_OUT
