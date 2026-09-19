// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

namespace aios {

struct ModelHeader {
    uint32_t magic;
    uint32_t version;
    uint32_t feature_id;
    uint32_t input_dim;
    uint32_t output_dim;
    uint32_t quant_scale_q;
    uint32_t reserved[3];
};

constexpr uint32_t MODEL_MAGIC = 0x41494F53;  // "AIOS"

enum class FeatureId : uint32_t {
    kAudioEraser = 0,
    kBrowsingAssist = 1,
    kCallAssist = 2,
    kDrawingAssist = 3,
    kInterpreter = 4,
    kNoteAssist = 5,
    kNowBrief = 6,
    kPhotoAssist = 7,
    kSemanticSearch = 8,
    kTranscriptAssist = 9,
    kWritingAssist = 10,
};

bool load_model(const std::string &path, ModelHeader *header, std::vector<uint8_t> *weights);

}  // namespace aios
