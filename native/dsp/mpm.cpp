#include "mpm.h"
#include "fft.h"
#include <string.h>
#include <math.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// MPM (McLeod Pitch Method) 参数
#define MPM_MIN_FREQ 50.0f
#define MPM_MAX_FREQ 5000.0f
#define MPM_FRAME_SIZE 4096

static float* mpm_window = NULL;
static float* mpm_real = NULL;
static float* mpm_imag = NULL;
static int mpm_initialized = 0;

void mpm_init(int sample_rate) {
    if (mpm_initialized) return;
    mpm_window = (float*)malloc(MPM_FRAME_SIZE * sizeof(float));
    mpm_real = (float*)malloc(MPM_FRAME_SIZE * sizeof(float));
    mpm_imag = (float*)malloc(MPM_FRAME_SIZE * sizeof(float));
    hann_window(mpm_window, MPM_FRAME_SIZE);
    mpm_initialized = 1;
}

// 计算 NSDF (Normalized Square Difference Function)
static void compute_nsdf(const float* samples, int n, float* nsdf) {
    // 使用 FFT 加速自相关计算
    int fft_size = 1;
    while (fft_size < 2 * n) fft_size <<= 1;

    float* real = (float*)calloc(fft_size, sizeof(float));
    float* imag = (float*)calloc(fft_size, sizeof(float));
    float* real2 = (float*)calloc(fft_size, sizeof(float));
    float* imag2 = (float*)calloc(fft_size, sizeof(float));

    // r = IFFT(FFT(x)^2)
    for (int i = 0; i < n; i++) {
        real[i] = samples[i];
    }
    fft(real, imag, fft_size);

    for (int i = 0; i < fft_size; i++) {
        float re = real[i], im = imag[i];
        real2[i] = re * re + im * im;
        imag2[i] = 0;
    }

    // IFFT: 对 real2 做共轭 FFT 再取共轭除以 N
    for (int i = 0; i < fft_size; i++) imag2[i] = -imag2[i];
    // 实际上 real2 全为实数，imag2 = 0
    fft(real2, imag2, fft_size);
    // FFT 后需要共轭处理... 直接用正变换的结果

    // 简化：直接计算自相关（对于大 frame 用 FFT 不划算，且需要正确处理）
    free(real);
    free(imag);
    free(real2);
    free(imag2);

    // 直接计算 NSDF
    for (int tau = 0; tau < n; tau++) {
        float acf = 0, m = 0;
        for (int i = 0; i < n - tau; i++) {
            acf += samples[i] * samples[i + tau];
            m += samples[i] * samples[i] + samples[i + tau] * samples[i + tau];
        }
        nsdf[tau] = m > 0 ? 2.0f * acf / m : 1.0f;
    }
}

// 抛物线插值
static float parabolic_interpolation(const float* array, int x, int n) {
    if (x <= 0 || x >= n - 1) return (float)x;
    float s0 = array[x - 1];
    float s1 = array[x];
    float s2 = array[x + 1];
    float adjustment = (s2 - s0) / (2.0f * (2.0f * s1 - s2 - s0));
    return (float)x + adjustment;
}

// 在 NSDF 中找峰值
static int find_peaks(const float* nsdf, int n, float threshold, int* peak_positions, float* peak_values, int max_peaks) {
    int count = 0;
    for (int i = 1; i < n - 1 && count < max_peaks; i++) {
        if (nsdf[i] > threshold && nsdf[i] > nsdf[i - 1] && nsdf[i] > nsdf[i + 1]) {
            // 检查是否是局部最大值
            int is_max = 1;
            for (int j = i - 2; j <= i + 2 && j < n; j++) {
                if (j != i && j >= 0 && nsdf[j] >= nsdf[i]) {
                    is_max = 0;
                    break;
                }
            }
            if (is_max) {
                peak_positions[count] = i;
                peak_values[count] = nsdf[i];
                count++;
            }
        }
    }
    return count;
}

float mpm_detect_pitch(const float* samples, int sample_count, int sample_rate) {
    mpm_init(sample_rate);

    int frame_size = MPM_FRAME_SIZE;
    if (sample_count < frame_size) frame_size = sample_count;

    // 加窗
    float* windowed = (float*)malloc(frame_size * sizeof(float));
    for (int i = 0; i < frame_size; i++) {
        windowed[i] = samples[i] * mpm_window[i];
    }

    // 计算 NSDF
    float* nsdf = (float*)malloc(frame_size * sizeof(float));
    compute_nsdf(windowed, frame_size, nsdf);

    free(windowed);

    // 找峰值
    int peak_positions[32];
    float peak_values[32];
    float threshold = 0.8f; // NSDF 阈值
    int num_peaks = find_peaks(nsdf, frame_size, threshold, peak_positions, peak_values, 32);

    if (num_peaks == 0) {
        free(nsdf);
        return 0.0f;
    }

    // 找最高峰值（对应基频）
    float best_peak = peak_values[0];
    int best_pos = peak_positions[0];

    for (int i = 1; i < num_peaks; i++) {
        if (peak_values[i] > best_peak) {
            best_peak = peak_values[i];
            best_pos = peak_positions[i];
        }
    }

    // 转换为频率
    if (best_pos <= 0) {
        free(nsdf);
        return 0.0f;
    }

    float refined = parabolic_interpolation(nsdf, best_pos, frame_size);
    float freq = (float)sample_rate / refined;

    free(nsdf);

    // 频率范围检查
    if (freq < MPM_MIN_FREQ || freq > MPM_MAX_FREQ) {
        return 0.0f;
    }

    return freq;
}
