// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later
//
// aiosd entry point. Loads the AIOS feature configuration, starts the RPC
// server on /dev/socket/aiosd and dispatches requests to the on-device
// Galaxy AI inferencing stack.

#include <unistd.h>
#include <cstdio>
#include <cstring>
#include <csignal>

#include "aiosd.hpp"
#include "rpc_server.hpp"
#include "config.hpp"

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

    aios::Config config;
    if (!aios::load_default_config(&config)) {
        fprintf(stderr, "aiosd: failed to load configuration\n");
        return 1;
    }

    aios::RpcServer server(config);
    if (!server.start()) {
        fprintf(stderr, "aiosd: failed to bind RPC socket\n");
        return 1;
    }

    while (g_running) {
        server.poll();
    }

    server.stop();
    return 0;
}
