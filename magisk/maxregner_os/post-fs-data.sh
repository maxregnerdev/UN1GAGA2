#!/system/bin/sh
# Maxregner OS 2.0 — post-fs-data boot hook.
# Runs at the post-fs-data stage under Magisk. Sets the ro.maxregner.* flags
# that the firmware-injected Lio/mesalabs/unica/Maxregner*; helpers read at
# class-init. The RRO overlays shipped under system/product/overlay/ are
# picked up by the framework from the module's magisk system mirror, so no
# manual overlay registration is needed.

# --- Glass: window blur + rounded corners ---
setprop ro.maxregner.glass.enabled true
setprop ro.maxregner.glass.blur_radius 32
setprop ro.maxregner.glass.rounded true
setprop ro.surface_flinger.supports_background_blur true
setprop debug.sf.use_blur_path true 2>/dev/null

# --- Spatial: depth + parallax ---
setprop ro.maxregner.spatial.enabled true
setprop ro.maxregner.spatial.parallax_amplitude 0.06
setprop ro.maxregner.spatial.depth_layers true
setprop ro.maxregner.spatial.gyro_driven true

# --- Orb v3: navigation ---
setprop ro.maxregner.orb3.enabled true
setprop ro.maxregner.orb3.version 3
setprop ro.maxregner.orb3.spring_stiffness 0.62
setprop ro.maxregner.orb3.spring_damping 0.78
setprop ro.maxregner.orb3.dwell_threshold_ms 180
setprop ro.maxregner.orb3.gesture_field true
setprop ro.maxregner.orb3.fluid_morph true
setprop ro.maxregner.orb3.idle_breath true

# --- Flux: adaptive refresh rate ---
setprop ro.maxregner.flux.enabled true
setprop ro.maxregner.flux.mode 2
setprop ro.maxregner.flux.min_hz 10
setprop ro.maxregner.flux.max_hz 120
setprop ro.maxregner.flux.idle_hz 24
setprop ro.maxregner.flux.content_aware true

# --- Aero: motion engine ---
setprop ro.maxregner.aero.enabled true
setprop ro.maxregner.aero.motion_scale 1.0
setprop ro.maxregner.aero.overshoot true
setprop ro.maxregner.aero.ambient_noise true

# --- Aura: ambient color temperature ---
setprop ro.maxregner.aura.enabled true
setprop ro.maxregner.aura.adaptive_kelvin true
setprop ro.maxregner.aura.min_kelvin 2500
setprop ro.maxregner.aura.max_kelvin 7500
setprop ro.maxregner.aura.ease_alpha 0.08

# --- Synth: audio/haptic synthesis ---
setprop ro.maxregner.synth.enabled true
setprop ro.maxregner.synth.amplitude 1.0
setprop ro.maxregner.synth.haptic_choreo true
setprop ro.maxregner.synth.default_wave 0

# --- Vault: privacy policy engine ---
setprop ro.maxregner.vault.enabled true
setprop ro.maxregner.vault.auto_revoke true
setprop ro.maxregner.vault.auto_revoke_ms 7200000
setprop ro.maxregner.vault.clipboard_guard true
setprop ro.maxregner.vault.sensor_guard true

# --- Cloud: ambient compute coordinator ---
setprop ro.maxregner.cloud.enabled true
setprop ro.maxregner.cloud.budget_cpu_pct 50
setprop ro.maxregner.cloud.budget_ram_mb 512
setprop ro.maxregner.cloud.min_charge_pct 80
setprop ro.maxregner.cloud.defer_low_priority true

# Mark the maxregner on-top OS layer as active for the Maxregner settings panel.
setprop ro.maxregner.os.active true
setprop ro.maxregner.os.version 2
setprop ro.maxregner.os.build 39
