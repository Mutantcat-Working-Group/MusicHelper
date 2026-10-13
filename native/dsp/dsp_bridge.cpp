#include "dsp_bridge.h"
#include "mpm.h"
#include "chord_detector.h"
#include "fft.h"
#include <math.h>
#include <string.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

static int g_sample_rate = 44100;
static float* g_window = NULL;
static float* g_real = NULL;
static float* g_imag = NULL;
static int g_fft_size = 4096;
static int g_initialized = 0;

void dsp_init(int sample_rate) {
    if (g_initialized) return;
    g_sample_rate = sample_rate;

    mpm_init(sample_rate);

    g_window = (float*)malloc(g_fft_size * sizeof(float));
    g_real = (float*)malloc(g_fft_size * sizeof(float));
    g_imag = (float*)calloc(g_fft_size, sizeof(float));

    hann_window(g_window, g_fft_size);
    g_initialized = 1;
}

void dsp_cleanup(void) {
    free(g_window);
    free(g_real);
    free(g_imag);
    g_window = NULL;
    g_real = NULL;
    g_imag = NULL;
    g_initialized = 0;
}

float mpm_detect_pitch(const float* samples, int sample_count, int sample_rate) {
    return mpm_detect_pitch(samples, sample_count, sample_rate);
}

MultiPitchResult detect_multiple_pitches(const float* samples, int sample_count, int sample_rate) {
    return detect_multiple_pitches(samples, sample_count, sample_rate);
}

ChordResult detect_chord(const float* samples, int sample_count, int sample_rate) {
    ChordResult result;
    memset(&result, 0, sizeof(result));

    dsp_init(sample_rate);

    int fft_size = g_fft_size;
    if (sample_count < fft_size) fft_size = sample_count;

    // 加窗并 FFT
    for (int i = 0; i < fft_size; i++) {
        g_real[i] = (i < sample_count ? samples[i] : 0.0f) * g_window[i];
        g_imag[i] = 0;
    }

    fft(g_real, g_imag, fft_size);

    // 计算幅度谱
    int bin_count = fft_size / 2;
    float* mags = (float*)malloc(bin_count * sizeof(float));
    for (int i = 0; i < bin_count; i++) {
        mags[i] = sqrtf(g_real[i] * g_real[i] + g_imag[i] * g_imag[i]);
    }

    // 计算 chroma 特征
    float chroma[12];
    compute_chroma(mags, bin_count, chroma, sample_rate, fft_size);

    // 模板匹配
    result = match_chord_from_chroma(chroma);

    free(mags);
    return result;
}
