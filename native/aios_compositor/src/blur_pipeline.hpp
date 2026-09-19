// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "vulkan_context.hpp"

namespace aios {
namespace vk {

class BlurPipeline {
public:
    explicit BlurPipeline(Context &context);
    ~BlurPipeline() = default;

    bool initialize();
    void destroy();
    bool render_frame();

    void set_blur_radius(uint32_t radius) { blur_radius_ = radius; }
    uint32_t blur_radius() const { return blur_radius_; }

private:
    Context &context_;
    uint32_t blur_radius_ = 16;
};

}  // namespace vk
}  // namespace aios
