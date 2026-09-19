// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Local socket RPC server. Framework-side AIOS clients connect to
// /dev/socket/aiosd and issue fixed-size request records; responses carry a
// status code plus payload. No binder dependency: the daemon must start
// before the framework and survive its restarts.

#include "rpc_server.hpp"

#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <cerrno>
#include <cstdio>
#include <cstring>

namespace aios {

namespace {

constexpr const char *kSocketPath = "/dev/socket/aiosd";
constexpr size_t kMaxClients = 16;

}  // namespace

RpcServer::RpcServer(const Config &config)
    : config_(config), listen_fd_(-1)
{
    memset(clients_, 0, sizeof(clients_));
}

RpcServer::~RpcServer()
{
    stop();
}

bool RpcServer::start()
{
    listen_fd_ = socket(AF_UNIX, SOCK_SEQPACKET | SOCK_NONBLOCK | SOCK_CLOEXEC, 0);
    if (listen_fd_ < 0) {
        return false;
    }

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, kSocketPath, sizeof(addr.sun_path) - 1);

    unlink(kSocketPath);
    if (bind(listen_fd_, reinterpret_cast<struct sockaddr *>(&addr), sizeof(addr)) != 0) {
        close(listen_fd_);
        listen_fd_ = -1;
        return false;
    }

    if (listen(listen_fd_, kMaxClients) != 0) {
        close(listen_fd_);
        listen_fd_ = -1;
        return false;
    }
    return true;
}

void RpcServer::stop()
{
    if (listen_fd_ >= 0) {
        close(listen_fd_);
        listen_fd_ = -1;
    }
    unlink(kSocketPath);
    for (size_t i = 0; i < kMaxClients; ++i) {
        if (clients_[i] >= 0) {
            close(clients_[i]);
            clients_[i] = -1;
        }
    }
}

void RpcServer::poll()
{
    fd_set read_set;
    FD_ZERO(&read_set);
    FD_SET(listen_fd_, &read_set);
    int max_fd = listen_fd_;

    for (size_t i = 0; i < kMaxClients; ++i) {
        if (clients_[i] >= 0) {
            FD_SET(clients_[i], &read_set);
            if (clients_[i] > max_fd) {
                max_fd = clients_[i];
            }
        }
    }

    timeval timeout;
    timeout.tv_sec = 1;
    timeout.tv_usec = 0;

    int ready = select(max_fd + 1, &read_set, nullptr, nullptr, &timeout);
    if (ready <= 0) {
        return;
    }

    if (FD_ISSET(listen_fd_, &read_set)) {
        int fd = accept4(listen_fd_, nullptr, nullptr, SOCK_CLOEXEC);
        if (fd >= 0) {
            for (size_t i = 0; i < kMaxClients; ++i) {
                if (clients_[i] < 0) {
                    clients_[i] = fd;
                    break;
                }
            }
        }
    }

    for (size_t i = 0; i < kMaxClients; ++i) {
        if (clients_[i] >= 0 && FD_ISSET(clients_[i], &read_set)) {
            if (!handle_client(clients_[i])) {
                close(clients_[i]);
                clients_[i] = -1;
            }
        }
    }
}

bool RpcServer::handle_client(int fd)
{
    RpcRequest request;
    ssize_t n = recv(fd, &request, sizeof(request), MSG_DONTWAIT);
    if (n <= 0) {
        return false;
    }
    if (static_cast<size_t>(n) < offsetof(RpcRequest, payload) + request.payload_len) {
        return false;
    }

    RpcResponse response;
    memset(&response, 0, sizeof(response));
    response.request_id = request.request_id;
    response.status = dispatch(request, response.payload, &response.payload_len);

    n = send(fd, &response, offsetof(RpcResponse, payload) + response.payload_len, MSG_DONTWAIT);
    return n > 0;
}

int32_t RpcServer::dispatch(const RpcRequest &request, uint8_t *payload, uint32_t *payload_len)
{
    switch (static_cast<FeatureId>(request.feature_id)) {
    case FeatureId::kAudioEraser:
        return audio_eraser_handler(request, payload, payload_len);
    default:
        *payload_len = 0;
        return kStatusUnsupported;
    }
}

int32_t RpcServer::audio_eraser_handler(const RpcRequest &request, uint8_t *payload,
                                        uint32_t *payload_len)
{
    if (request.payload_len < sizeof(AudioEraserRequest)) {
        return kStatusBadPayload;
    }
    AudioEraserRequest eraser_request;
    memcpy(&eraser_request, request.payload, sizeof(eraser_request));
    eraser_.set_noise_profile(eraser_request.noise_profile);

    size_t channels = std::min<size_t>(eraser_request.channels, dsp::AudioEraser::kMaxChannels);
    size_t frames = eraser_.process(reinterpret_cast<const int16_t *>(eraser_request.samples),
                                     reinterpret_cast<int16_t *>(payload),
                                     eraser_request.sample_count, channels);
    *payload_len = static_cast<uint32_t>(frames * sizeof(int16_t));
    return kStatusOk;
}

}  // namespace aios
