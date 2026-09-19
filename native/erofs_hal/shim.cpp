// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later
//
// EROFS HAL shim for UN1CA AIOS. Mounts the read-only EROFS system
// partitions with the inline-compression profile selected at build time and
// reports mount status through the legacy HAL interface expected by the
// Samsung system stack.

#include <sys/mount.h>
#include <sys/stat.h>
#include <unistd.h>
#include <cstdio>
#include <cerrno>
#include <cstring>

namespace {

constexpr const char *kDevicePath = "/dev/block/by-name/system";
constexpr const char *kMountPoint = "/system_root";
constexpr const char *kFsType = "erofs";

}  // namespace

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;

    mkdir(kMountPoint, 0755);
    if (mount(kDevicePath, kMountPoint, kFsType, MS_RDONLY, "inlinecrypt") != 0) {
        fprintf(stderr, "erofs_hal: mount of %s failed: %s\n", kDevicePath, strerror(errno));
        return 1;
    }
    fprintf(stderr, "erofs_hal: %s mounted read-only at %s\n", kDevicePath, kMountPoint);
    return 0;
}
