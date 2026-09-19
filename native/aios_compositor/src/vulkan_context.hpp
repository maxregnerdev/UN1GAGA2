// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <cstdint>
#include <vector>

#include <vulkan/vulkan.h>

namespace aios {
namespace vk {

class Context {
public:
    Context() = default;
    ~Context() = default;

    bool initialize();
    void destroy();

    bool acquire_frame();
    bool present_frame();

    VkDevice device() const { return device_; }
    VkQueue graphics_queue() const { return graphics_queue_; }
    uint32_t graphics_queue_family() const { return graphics_queue_family_; }
    VkCommandBuffer command_buffer() const { return command_buffer_; }
    int32_t frame_width() const { return frame_width_; }
    int32_t frame_height() const { return frame_height_; }

private:
    bool create_instance();
    bool pick_physical_device();
    bool create_device();

    VkInstance instance_ = VK_NULL_HANDLE;
    VkPhysicalDevice physical_device_ = VK_NULL_HANDLE;
    VkDevice device_ = VK_NULL_HANDLE;
    VkQueue graphics_queue_ = VK_NULL_HANDLE;
    VkCommandPool command_pool_ = VK_NULL_HANDLE;
    VkCommandBuffer command_buffer_ = VK_NULL_HANDLE;
    uint32_t graphics_queue_family_ = 0;
    int32_t frame_width_ = 1080;
    int32_t frame_height_ = 2220;
};

}  // namespace vk
}  // namespace aios
