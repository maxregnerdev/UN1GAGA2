# Maxregner Cloud (maxregner_cloud) — real firmware injection
#
# The 0001-Introduce-MaxregnerCloud.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerCloud; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class is the real on-device
# ambient compute coordinator: it reads ro.maxregner.cloud.* props, resolves
# the device power state (IDLE/CHARGING/BUDGET) via resolveState(charging,
# chargePct, ...) and gates background compute by priority + resource budget
# via shouldRun(priority, cpuPct, ramMb, state). Low-priority work only runs
# when charging or above the min charge; high-priority always runs.

LOG_STEP_IN "- Injecting Maxregner Cloud ambient-compute coordinator"

# Cloud enable flag read by MaxregnerCloud.readEnabled().
SET_PROP "system" "ro.maxregner.cloud.enabled" "true"
SET_PROP "system" "ro.maxregner.cloud.budget_cpu_pct" "50"
SET_PROP "system" "ro.maxregner.cloud.budget_ram_mb" "512"
SET_PROP "system" "ro.maxregner.cloud.min_charge_pct" "80"
SET_PROP "system" "ro.maxregner.cloud.defer_low_priority" "true"

LOG_STEP_OUT
