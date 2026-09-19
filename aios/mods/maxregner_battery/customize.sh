# Maxregner Battery Intelligence
#
# Beyond One UI's fixed charging schedule. Maxregner learns the daily
# plug/unplug pattern and adapts the charge curve so the pack spends less
# time held at 100%. Adds thermal-aware charge caps and an idle discharge
# hold so a phone left plugged overnight does not cycle at full voltage.

LOG_STEP_IN "- Applying Maxregner Battery Intelligence"

# Advertise the Maxregner battery intelligence subsystem.
SET_PROP "system" "ro.maxregner.battery.enabled" "true"
SET_PROP "system" "ro.maxregner.battery.version" "1"

# Adaptive charge curve based on learned usage patterns.
SET_PROP "system" "persist.sys.maxregner.battery.adaptive_charge" "true"
SET_PROP "system" "persist.sys.maxregner.battery.learn_pattern" "true"
SET_PROP "system" "persist.sys.maxregner.battery.pattern_window_hours" "24"

# Thermal-aware charge cap: cap the charge current when the cell exceeds the
# set temperature threshold, protecting long-term pack health.
SET_PROP "system" "persist.sys.maxregner.battery.thermal_cap" "true"
SET_PROP "system" "persist.sys.maxregner.battery.thermal_threshold_c" "38"
SET_PROP "system" "persist.sys.maxregner.battery.thermal_max_current_ma" "1500"

# Idle discharge hold: once the pack reaches the target SoC while still on
# charger, hold it in a 40-60% band instead of sitting at 100%.
SET_PROP "system" "persist.sys.maxregner.battery.idle_hold" "true"
SET_PROP "system" "persist.sys.maxregner.battery.idle_hold_min" "40"
SET_PROP "system" "persist.sys.maxregner.battery.idle_hold_max" "60"

# End-of-charge ceiling (user tunable from Settings).
SET_PROP "system" "persist.sys.maxregner.battery.charge_ceiling" "85"

LOG_STEP_OUT
