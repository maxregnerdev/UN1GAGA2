// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Native DSP pipeline backing the Audio Eraser feature: splits a mono or
// stereo PCM stream into a set of spectral band masks and filters background
// noise components before handing the result back to the caller.

#include "audio_dsp.hpp"

#include <algorithm>
#include <cmath>
#include <cstring>

namespace aios {
namespace dsp {

namespace {

constexpr size_t kFrameSize = 512;
constexpr size_t kHopSize = 256;

void window(const float *in, float *out)
{
    for (size_t i = 0; i < kFrameSize; ++i) {
        out[i] = in[i] * (0.5f - 0.5f * cosf(2.0f * static_cast<float>(M_PI) * i / kFrameSize));
    }
}

void inverse_window(const float *in, float *out)
{
    window(in, out);
}

}  // namespace

AudioEraser::AudioEraser()
{
    memset(prev_overlap_, 0, sizeof(prev_overlap_));
    memset(workspace_, 0, sizeof(workspace_));
    set_noise_profile(kDefaultNoiseProfile);
}

void AudioEraser::set_noise_profile(float profile)
{
    profile_ = std::min(std::max(profile, 0.0f), 1.0f);
}

float AudioEraser::noise_profile() const
{
    return profile_;
}

size_t AudioEraser::process(const int16_t *in, int16_t *out, size_t samples, size_t channels)
{
    size_t produced = 0;
    size_t frame_count = samples / channels;

    for (size_t f = 0; f + kFrameSize <= frame_count; f += kHopSize) {
        for (size_t c = 0; c < channels && c < kMaxChannels; ++c) {
            float frame_in[kFrameSize];
            float frame_out[kFrameSize];

            for (size_t i = 0; i < kFrameSize; ++i) {
                frame_in[i] = static_cast<float>(in[(f + i) * channels + c]);
            }
            window(frame_in, frame_out);
            spectral_denoise(frame_out);
            inverse_window(frame_out, frame_out);

            for (size_t i = 0; i < kFrameSize; ++i) {
                workspace_[c][i] += frame_out[i];
            }
        }

        for (size_t i = 0; i < kHopSize; ++i) {
            for (size_t c = 0; c < channels && c < kMaxChannels; ++c) {
                float v = workspace_[c][i] + prev_overlap_[c][i];
                v = std::min(std::max(v, -32768.0f), 32767.0f);
                out[(produced + i) * channels + c] = static_cast<int16_t>(v);
                prev_overlap_[c][i] = workspace_[c][i + kHopSize];
            }
            for (size_t c = 0; c < kMaxChannels; ++c) {
                workspace_[c][i] = 0.0f;
                workspace_[c][i + kHopSize] = 0.0f;
            }
        }
        produced += kHopSize;
    }
    return produced * channels;
}

void AudioEraser::spectral_denoise(float *frame)
{
    float energy = 0.0f;
    for (size_t i = 0; i < kFrameSize; ++i) {
        energy += frame[i] * frame[i];
    }
    float threshold = std::sqrt(energy / kFrameSize) * profile_;
    for (size_t i = 0; i < kFrameSize; ++i) {
        float sign = frame[i] < 0.0f ? -1.0f : 1.0f;
        float mag = std::fabs(frame[i]);
        if (mag < threshold) {
            frame[i] *= (1.0f - profile_);
        } else {
            frame[i] = sign * (mag - threshold);
        }
    }
}

}  // namespace dsp
}  // namespace aios
