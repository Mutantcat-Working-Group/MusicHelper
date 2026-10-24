#include "dsp_bridge.h"
#include "chord_detector.h"
#include "fft.h"
#include <math.h>
#include <string.h>
#include <stdlib.h>

static int g_sample_rate = 44100;

void dsp_init(int sample_rate) {
    if (sample_rate > 0) g_sample_rate = sample_rate;
}

void dsp_cleanup(void) {
    // 所有工作缓冲区都在调用栈上按需分配,没有需要释放的全局状态
}

// 和弦检测:FFT -> 幅度谱 -> chroma -> 模板匹配
void detect_chord(const float* samples, int sample_count, int sample_rate, ChordResult* out) {
    if (out == NULL) return;
    memset(out, 0, sizeof(ChordResult));
    if (samples == NULL || sample_count <= 0) return;
    if (sample_rate <= 0) sample_rate = g_sample_rate;

    const int fft_size = DSP_FFT_SIZE;
    float* real = (float*)malloc((size_t)fft_size * sizeof(float));
    float* imag = (float*)calloc((size_t)fft_size, sizeof(float));
    float* window = (float*)malloc((size_t)fft_size * sizeof(float));
    if (!real || !imag || !window) {
        free(real); free(imag); free(window);
        return;
    }

    prepare_analysis_frame(samples, sample_count, fft_size, real);
    hann_window(window, fft_size);
    for (int i = 0; i < fft_size; i++) real[i] *= window[i];

    fft(real, imag, fft_size);

    int bin_count = fft_size / 2;
    float* mags = (float*)malloc((size_t)bin_count * sizeof(float));
    if (!mags) {
        free(real); free(imag); free(window);
        return;
    }
    for (int i = 0; i < bin_count; i++) {
        mags[i] = sqrtf(real[i] * real[i] + imag[i] * imag[i]);
    }

    float chroma[12];
    compute_chroma(mags, bin_count, chroma, sample_rate, fft_size);
    *out = match_chord_from_chroma(chroma);

    free(mags);
    free(real);
    free(imag);
    free(window);
}
