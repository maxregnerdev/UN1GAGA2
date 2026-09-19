// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later

#include "config.hpp"

#include <cstdlib>

namespace aios {

bool load_default_config(Config *config)
{
    if (!config) {
        return false;
    }
    const char *model_dir = getenv("AIOSD_MODEL_DIR");
    if (model_dir && model_dir[0] != '\0') {
        config->model_dir = model_dir;
    }
    return true;
}

}  // namespace aios
