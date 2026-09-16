# Maxregner Synth (maxregner_synth) — real firmware injection
#
# The 0001-Introduce-MaxregnerSynth.patch adds a new self-contained helper
# class Lio/mesalabs/unica/MaxregnerSynth; to framework.jar. apktool compiles
# it into the firmware's framework DEX. The class is the real audio/haptic
# synthesis core: it reads ro.maxregner.synth.* props, generates procedural
# waveform samples (sine / square / triangle) via synth(wave, freq, delta)
# for the UI sound scheme, and computes haptic envelope curves via
# hapticEnvelope(elapsedMs, durationMs) so haptic effects choreograph to
# the synth output instead of being a fixed tick.

LOG_STEP_IN "- Injecting Maxregner Synth audio/haptic engine"

# Synth enable flag read by MaxregnerSynth.readEnabled().
SET_PROP "system" "ro.maxregner.synth.enabled" "true"
SET_PROP "system" "ro.maxregner.synth.amplitude" "1.0"
SET_PROP "system" "ro.maxregner.synth.haptic_choreo" "true"
SET_PROP "system" "ro.maxregner.synth.default_wave" "sine"

LOG_STEP_OUT
