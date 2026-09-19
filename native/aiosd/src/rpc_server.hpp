// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <cstddef>
#include <cstdint>
#include <cstring>

#include "aiosd.hpp"
#include "audio_dsp.hpp"
#include "config.hpp"

namespace aios {

constexpr uint32_t kMaxPayloadLen = 64 * 1024;

struct RpcRequest {
    uint32_t request_id;
    uint32_t feature_id;
    uint32_t payload_len;
    uint8_t payload[kMaxPayloadLen];
};

struct RpcResponse {
    uint32_t request_id;
    int32_t status;
    uint32_t payload_len;
    uint8_t payload[kMaxPayloadLen];
};

constexpr int32_t kStatusOk = 0;
constexpr int32_t kStatusUnsupported = 1;
constexpr int32_t kStatusBadPayload = 2;

struct AudioEraserRequest {
    uint32_t sample_count;
    uint32_t channels;
    uint32_t sample_rate;
    float noise_profile;
    int16_t samples[0];
};

class RpcServer {
public:
    explicit RpcServer(const Config &config);
    ~RpcServer();

    bool start();
    void stop();
    void poll();

private:
    static constexpr size_t kMaxClients = 16;

    bool handle_client(int fd);
    int32_t dispatch(const RpcRequest &request, uint8_t *payload, uint32_t *payload_len);
    int32_t audio_eraser_handler(const RpcRequest &request, uint8_t *payload, uint32_t *payload_len);

    const Config &config_;
    int listen_fd_;
    int clients_[kMaxClients];
    dsp::AudioEraser eraser_;
};

}  // namespace aios
