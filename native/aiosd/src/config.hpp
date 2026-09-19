// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <cstdint>
#include <string>

namespace aios {

struct Config {
    std::string model_dir = "/system/etc/aios/models";
    std::string socket_path = "/dev/socket/aiosd";
    bool enable_audio_eraser = true;
    bool enable_browsing_assist = true;
    bool enable_call_assist = true;
    bool enable_drawing_assist = true;
    bool enable_interpreter = true;
    bool enable_note_assist = true;
    bool enable_now_brief = true;
    bool enable_photo_assist = true;
    bool enable_semantic_search = true;
    bool enable_transcript_assist = true;
    bool enable_writing_assist = true;
};

bool load_default_config(Config *config);

}  // namespace aios
