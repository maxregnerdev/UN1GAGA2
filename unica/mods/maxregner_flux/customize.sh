# Maxregner Flux (maxregner_flux) — real firmware injection
#
# The 0001-Introduce-MaxregnerFlux.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerFlux; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class is the real adaptive
# refresh-rate engine: it reads ro.maxregner.flux.* props, runs a frame
# interval analyzer over the per-frame timestamp stream, and exposes the
# resolved target Hz to the SurfaceFlinger refresh-rate arbitrator via
# onFrame(timestampMs) -> currentHz. Modes: OFF / FIXED / ADAPTIVE / CONTENT.

LOG_STEP_IN "- Injecting Maxregner Flux adaptive refresh engine"

# Flux enable flag + mode read by MaxregnerFlux.readEnabled() / readMode().
SET_PROP "system" "ro.maxregner.flux.enabled" "true"
SET_PROP "system" "ro.maxregner.flux.mode" "adaptive"
SET_PROP "system" "ro.maxregner.flux.min_hz" "10"
SET_PROP "system" "ro.maxregner.flux.max_hz" "120"
SET_PROP "system" "ro.maxregner.flux.idle_hz" "24"
SET_PROP "system" "ro.maxregner.flux.content_aware" "true"

LOG_STEP_OUT
