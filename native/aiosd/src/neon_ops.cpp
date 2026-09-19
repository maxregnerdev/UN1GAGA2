// Copyright (c) 2026 maxregner
// SPDX-License-Identifier: GPL-3.0-or-later
//
// ARM NEON accelerated tensor operators for the aiosd quantized inference
// path. Targets the Exynos 8895 big cluster (Mongoose M2, ARMv8-A + SIMD).

#include "neon_ops.hpp"

#if defined(__ARM_NEON) || defined(__aarch64__)
#include <arm_neon.h>
#define AIOS_HAVE_NEON 1
#else
#define AIOS_HAVE_NEON 0
#endif

namespace aios {
namespace neon {

void quantized_matmul(const int8_t *lhs, const int8_t *rhs, int32_t *out,
                      size_t m, size_t n, size_t k, int32_t lhs_zero_point,
                      int32_t rhs_zero_point)
{
#if AIOS_HAVE_NEON
    for (size_t i = 0; i < m; ++i) {
        const int8_t *lhs_row = lhs + i * k;
        int32_t *out_row = out + i * n;
        for (size_t j = 0; j < n; ++j) {
            const int8_t *rhs_col = rhs + j * k;
            int32x4_t acc = vdupq_n_s32(0);
            size_t p = 0;
            for (; p + 16 <= k; p += 16) {
                int8x16_t a = vld1q_s8(lhs_row + p);
                int8x16_t b = vld1q_s8(rhs_col + p);
                int16x8_t a_lo = vreinterpretq_s16_s8(vzip1q_s8(a, vdupq_n_s8(0)));
                int16x8_t a_hi = vreinterpretq_s16_s8(vzip2q_s8(a, vdupq_n_s8(0)));
                int16x8_t b_lo = vreinterpretq_s16_s8(vzip1q_s8(b, vdupq_n_s8(0)));
                int16x8_t b_hi = vreinterpretq_s16_s8(vzip2q_s8(b, vdupq_n_s8(0)));
                int32x4_t p0 = vmull_s16(vget_low_s16(a_lo), vget_low_s16(b_lo));
                int32x4_t p1 = vmull_s16(vget_high_s16(a_lo), vget_high_s16(b_lo));
                int32x4_t p2 = vmull_s16(vget_low_s16(a_hi), vget_low_s16(b_hi));
                int32x4_t p3 = vmull_s16(vget_high_s16(a_hi), vget_high_s16(b_hi));
                acc = vpadddq_s32(acc, vpaddq_s32(p0, p1));
                acc = vpaddq_s32(acc, vpaddq_s32(p2, p3));
            }
            int32_t sum = vaddvq_s32(acc);
            for (; p < k; ++p) {
                sum += static_cast<int32_t>(lhs_row[p] - lhs_zero_point) *
                       static_cast<int32_t>(rhs_col[p] - rhs_zero_point);
            }
            out_row[j] = sum;
        }
    }
#else
    (void)lhs_zero_point;
    (void)rhs_zero_point;
    for (size_t i = 0; i < m; ++i) {
        const int8_t *lhs_row = lhs + i * k;
        int32_t *out_row = out + i * n;
        for (size_t j = 0; j < n; ++j) {
            const int8_t *rhs_col = rhs + j * k;
            int32_t sum = 0;
            for (size_t p = 0; p < k; ++p) {
                sum += static_cast<int32_t>(lhs_row[p]) * static_cast<int32_t>(rhs_col[p]);
            }
            out_row[j] = sum;
        }
    }
#endif
}

void requantize(const int32_t *in, int8_t *out, size_t len, float scale, int8_t zero_point)
{
#if AIOS_HAVE_NEON
    float32x4_t vscale = vdupq_n_f32(scale);
    for (size_t i = 0; i < len; i += 4) {
        int32x4_t v = vld1q_s32(in + i);
        float32x4_t f = vmulq_f32(vcvtq_f32_s32(v), vscale);
        int32x4_t q = vcvtaq_s32_f32(f);
        q = vaddq_s32(q, vdupq_n_s32(static_cast<int32_t>(zero_point)));
        int16x4_t s = vqmovn_s32(q);
        int8x8_t r = vqmovn_s16(vcombine_s16(s, s));
        vst1_s8(out + i, r);
    }
#else
    for (size_t i = 0; i < len; ++i) {
        float f = static_cast<float>(in[i]) * scale;
        int32_t q = static_cast<int32_t>(f < 0 ? f - 0.5f : f + 0.5f) + zero_point;
        out[i] = static_cast<int8_t>(q < -128 ? -128 : (q > 127 ? 127 : q));
    }
#endif
}

}  // namespace neon
}  // namespace aios
