#include "mpm.h"
#include <math.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// MPM (McLeod Pitch Method) 参数
#define MPM_MIN_FREQ 28.0f   // 覆盖 5 弦贝斯最低音 B0 (~30.9Hz)
#define MPM_MAX_FREQ 5000.0f
#define MPM_FRAME_SIZE 4096

// NSDF 峰值必须达到的最高峰比例,低于此值认为信号不够周期性强
#define MPM_CLARITY 0.5f
// 选峰阈值:最高峰的 85%
#define MPM_PEAK_RATIO 0.85f

// 抛物线插值,返回亚样本级的峰值位置
static float parabolic_interpolation(const float* array, int x, int n) {
    if (x <= 0 || x >= n - 1) return (float)x;
    float s0 = array[x - 1];
    float s1 = array[x];
    float s2 = array[x + 1];
    float denom = 2.0f * (2.0f * s1 - s2 - s0);
    if (denom == 0.0f) return (float)x;
    float adjustment = (s2 - s0) / denom;
    if (adjustment > 1.0f) adjustment = 1.0f;
    if (adjustment < -1.0f) adjustment = -1.0f;
    return (float)x + adjustment;
}

float mpm_detect_pitch(const float* samples, int sample_count, int sample_rate) {
    if (samples == NULL || sample_count <= 0 || sample_rate <= 0) return 0.0f;

    int frame_size = MPM_FRAME_SIZE;
    if (sample_count < frame_size) frame_size = sample_count;
    if (frame_size < 64) return 0.0f; // 太短无法分析

    // 滞后搜索范围:对应 MPM_MIN_FREQ ~ MPM_MAX_FREQ
    int min_lag = (int)((float)sample_rate / MPM_MAX_FREQ);
    int max_lag = (int)((float)sample_rate / MPM_MIN_FREQ);
    if (min_lag < 2) min_lag = 2;
    if (max_lag >= frame_size) max_lag = frame_size - 1;
    if (min_lag >= max_lag) return 0.0f;

    int lag_count = max_lag - min_lag + 1;
    float* nsdf = (float*)malloc((size_t)lag_count * sizeof(float));
    // 前缀平方和:pss[k] = sum_{i<k} x[i]^2,用于 O(1) 计算归一化因子
    float* pss = (float*)malloc(((size_t)frame_size + 1) * sizeof(float));
    if (!nsdf || !pss) {
        free(nsdf);
        free(pss);
        return 0.0f;
    }

    pss[0] = 0.0f;
    for (int i = 0; i < frame_size; i++) {
        pss[i + 1] = pss[i] + samples[i] * samples[i];
    }

    // 直接在有效滞后范围内计算 NSDF。
    // m(tau) = sum_{i<n-tau} (x[i]^2 + x[i+tau]^2) = pss[n-tau] + (pss[n] - pss[tau])
    for (int tau = min_lag; tau <= max_lag; tau++) {
        int len = frame_size - tau;
        float acf = 0.0f;
        for (int i = 0; i < len; i++) {
            acf += samples[i] * samples[i + tau];
        }
        float m = pss[len] + (pss[frame_size] - pss[tau]);
        nsdf[tau - min_lag] = m > 0.0f ? 2.0f * acf / m : 0.0f;
    }

    // 1. 找最高峰,用于清晰度判断和相对阈值
    float max_val = 0.0f;
    for (int i = 0; i < lag_count; i++) {
        if (nsdf[i] > max_val) max_val = nsdf[i];
    }

    // 清晰度检查:最高峰太低说明信号不具周期性(噪声/静音)
    if (max_val < MPM_CLARITY) {
        free(nsdf);
        free(pss);
        return 0.0f;
    }

    // 2. 取阈值以上"第一个"局部极大值(而非最高峰),
    //    避免选到真实周期的整数倍(低八度误差)
    float threshold = max_val * MPM_PEAK_RATIO;
    int chosen = -1;
    for (int i = 1; i < lag_count - 1; i++) {
        if (nsdf[i] >= threshold &&
            nsdf[i] >= nsdf[i - 1] &&
            nsdf[i] >= nsdf[i + 1]) {
            chosen = i;
            break;
        }
    }

    if (chosen < 0) {
        free(nsdf);
        free(pss);
        return 0.0f;
    }

    // 3. 抛物线插值细化,转换为频率
    float refined = parabolic_interpolation(nsdf, chosen, lag_count);
    float lag = (float)min_lag + refined;
    if (lag <= 0.0f) {
        free(nsdf);
        free(pss);
        return 0.0f;
    }
    float freq = (float)sample_rate / lag;

    free(nsdf);
    free(pss);

    // 频率范围检查
    if (freq < MPM_MIN_FREQ || freq > MPM_MAX_FREQ) {
        return 0.0f;
    }

    return freq;
}
