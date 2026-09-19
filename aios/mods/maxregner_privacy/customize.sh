# Maxregner Privacy Guard
#
# System-wide privacy hardening that goes beyond One UI's per-app permission
# model. Adds clipboard read protection (block background clipboard reads),
# a sensor gate (deny sensor access to apps that never legitimately need it),
# a per-app network audit log, and clipboard auto-clear after a timeout.

LOG_STEP_IN "- Applying Maxregner Privacy Guard"

# Advertise the Maxregner privacy subsystem.
SET_PROP "system" "ro.maxregner.privacy.enabled" "true"
SET_PROP "system" "ro.maxregner.privacy.version" "1"

# Clipboard read protection: background apps cannot read the clipboard.
SET_PROP "system" "persist.sys.maxregner.privacy.clipboard_guard" "true"
SET_PROP "system" "persist.sys.maxregner.privacy.clipboard_auto_clear" "true"
SET_PROP "system" "persist.sys.maxregner.privacy.clipboard_clear_seconds" "30"

# Sensor gate: deny accelerometer/gyroscope/magnetometer to apps that do not
# need them (games/motion apps whitelisted via the sensor allowlist).
SET_PROP "system" "persist.sys.maxregner.privacy.sensor_gate" "true"
SET_PROP "system" "persist.sys.maxregner.privacy.sensor_gate_default" "deny"

# Per-app network audit: log outbound connections per package so the user can
# review unexpected network access.
SET_PROP "system" "persist.sys.maxregner.privacy.network_audit" "true"
SET_PROP "system" "persist.sys.maxregner.privacy.network_audit_log_size" "256"

# Connectivity hardening: strip the per-app NET capability disclosure so apps
# cannot fingerprint the network state beyond what they need.
SET_PROP "system" "persist.sys.maxregner.privacy.hide_net_state" "true"

LOG_STEP_OUT
