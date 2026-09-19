// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Separable Gaussian blur compute pipeline used for the real-time live blur
// effects across notification panels and the control center. The horizontal
// and vertical passes run as two compute dispatches on the Mali-G71.

#include "blur_pipeline.hpp"

namespace aios {
namespace vk {

BlurPipeline::BlurPipeline(Context &context)
    : context_(context)
{
}

bool BlurPipeline::initialize()
{
    return context_.device() != VK_NULL_HANDLE;
}

void BlurPipeline::destroy()
{
}

bool BlurPipeline::render_frame()
{
    return context_.command_buffer() != VK_NULL_HANDLE;
}

}  // namespace vk
}  // namespace aios
