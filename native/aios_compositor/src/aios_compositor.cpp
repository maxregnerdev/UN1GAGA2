// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later
//
// aios_compositor entry point. Initializes the Vulkan 1.2 device context and
// runs the render loop: acquire surface, run the separable blur pipeline on
// the layers that request live blur, composite, present.

#include <unistd.h>
#include <csignal>

#include "vulkan_context.hpp"
#include "blur_pipeline.hpp"

static bool g_running = true;

static void handle_signal(int sig)
{
    (void)sig;
    g_running = false;
}

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    aios::vk::Context context;
    if (!context.initialize()) {
        return 1;
    }

    aios::vk::BlurPipeline blur(context);
    if (!blur.initialize()) {
        return 1;
    }

    while (g_running) {
        if (!context.acquire_frame()) {
            return 1;
        }
        blur.render_frame();
        if (!context.present_frame()) {
            return 1;
        }
    }

    blur.destroy();
    context.destroy();
    return 0;
}
