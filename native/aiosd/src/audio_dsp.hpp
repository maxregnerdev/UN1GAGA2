// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <cstddef>
#include <cstdint>

namespace aios {
namespace dsp {

class AudioEraser {
public:
    static constexpr size_t kMaxChannels = 2;
    static constexpr float kDefaultNoiseProfile = 0.6f;

    AudioEraser();

    void set_noise_profile(float profile);
    float noise_profile() const;

    size_t process(const int16_t *in, int16_t *out, size_t samples, size_t channels);

private:
    static constexpr size_t kFrameSize = 512;
    static constexpr size_t kHopSize = 256;

    void spectral_denoise(float *frame);

    float profile_;
    float workspace_[kMaxChannels][kFrameSize];
    float prev_overlap_[kMaxChannels][kHopSize];
};

}  // namespace dsp
}  // namespace aios
