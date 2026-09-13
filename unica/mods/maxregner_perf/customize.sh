# Maxregner Performance & Security
#
# Extends the Maxregner system with a performance/power profile and a hardened
# sandbox profile. The governor, zram and ksm tunables are applied at boot by
# the Maxregner boot service; the props below advertise the active profile so
# the Maxregner settings surface can reflect it, and so the bundled init rc
# snippet is picked up on partitions that run init rc fragments.

LOG_STEP_IN "- Applying Maxregner performance profile"

# Active profile advertisement.
SET_PROP "system" "ro.maxregner.perf.enabled" "true"
SET_PROP "system" "ro.maxregner.perf.governor" "schedutil"
SET_PROP "system" "persist.sys.maxregner.perf.high_fps" "true"
SET_PROP "system" "persist.sys.maxregner.perf.zram_size" "2147483648"
SET_PROP "system" "persist.sys.maxregner.perf.ksm" "true"
SET_PROP "system" "persist.sys.maxregner.perf.dash_charging" "true"
SET_PROP "system" "ro.maxregner.perf.thermal_profile" "balanced"
SET_PROP "system" "persist.sys.maxregner.perf.background_limit" "32"
SET_PROP "system" "persist.sys.maxregner.perf.cache_reclaim" "aggressive"

LOG_STEP_OUT

LOG_STEP_IN "- Applying Maxregner security profile"

# Hardened sandbox / init profile (enforced at boot where possible).
SET_PROP "system" "ro.maxregner.sec.enabled" "true"
SET_PROP "system" "persist.sys.maxregner.sec.hardened_init" "true"
SET_PROP "system" "persist.sys.maxregner.sec.verity_logging" "true"
SET_PROP "system" "persist.sys.maxregner.sec.lockdown" "true"
SET_PROP "system" "ro.maxregner.sec.sandbox" "strict"

LOG_STEP_OUT
