// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <cstddef>
#include <cstdint>

namespace aios {
namespace neon {

void quantized_matmul(const int8_t *lhs, const int8_t *rhs, int32_t *out,
                      size_t m, size_t n, size_t k, int32_t lhs_zero_point,
                      int32_t rhs_zero_point);

void requantize(const int32_t *in, int8_t *out, size_t len, float scale, int8_t zero_point);

}  // namespace neon
}  // namespace aios
