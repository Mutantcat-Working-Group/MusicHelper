#include "chord_detector.h"
#include "fft.h"
#include <math.h>
#include <string.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// 分析帧长度统一在 dsp_bridge.h 的 DSP_FFT_SIZE(8192)
#define CHORD_MIN_FREQ 50.0f
#define CHORD_MAX_FREQ 5000.0f
#define HPS_HARMONICS 5

// 19 种和弦类型(与 Dart 侧 ChordQuality 对应)
// 0=major, 1=minor, 2=aug, 3=dim, 4=7, 5=maj7, 6=m7, 7=m7b5, 8=dim7,
// 9=sus2, 10=sus4, 11=6, 12=m6, 13=9, 14=maj9, 15=m9, 16=add9, 17=madd9, 18=dom9
static const int CHORD_INTERVALS[19][8] = {
    {0, 4, 7, 0, 0, 0, 0, 0},        // 0: major
    {0, 3, 7, 0, 0, 0, 0, 0},        // 1: minor
    {0, 4, 8, 0, 0, 0, 0, 0},        // 2: augmented
    {0, 3, 6, 0, 0, 0, 0, 0},        // 3: diminished
    {0, 4, 7, 10, 0, 0, 0, 0},       // 4: dominant 7
    {0, 4, 7, 11, 0, 0, 0, 0},       // 5: major 7
    {0, 3, 7, 10, 0, 0, 0, 0},       // 6: minor 7
    {0, 3, 6, 10, 0, 0, 0, 0},       // 7: minor 7b5
    {0, 3, 6, 9, 0, 0, 0, 0},        // 8: diminished 7
    {0, 2, 7, 0, 0, 0, 0, 0},        // 9: sus2
    {0, 5, 7, 0, 0, 0, 0, 0},        // 10: sus4
    {0, 4, 7, 9, 0, 0, 0, 0},        // 11: major 6
    {0, 3, 7, 9, 0, 0, 0, 0},        // 12: minor 6
    {0, 4, 7, 10, 14, 0, 0, 0},      // 13: dominant 9
    {0, 4, 7, 11, 14, 0, 0, 0},      // 14: major 9
    {0, 3, 7, 10, 14, 0, 0, 0},      // 15: minor 9
    {0, 4, 7, 14, 0, 0, 0},          // 16: add9
    {0, 3, 7, 14, 0, 0, 0},          // 17: madd9
    {0, 4, 7, 10, 14, 0, 0, 0},      // 18: dom9 (alias)
};

static const int CHORD_INTERVAL_COUNT[19] = {
    3, 3, 3, 3, 4, 4, 4, 4, 4,
    3, 3, 4, 4, 5, 5, 5, 4, 4, 5
};

// 判断 pitch_class 是否属于 (root, quality) 的构成音
static int is_chord_tone(int root, int quality, int pitch_class) {
    int count = CHORD_INTERVAL_COUNT[quality];
    for (int j = 0; j < count; j++) {
        if ((root + CHORD_INTERVALS[quality][j]) % 12 == pitch_class) return 1;
    }
    return 0;
}

// 计算 12 维 chroma 特征(从 FFT 频谱)
void compute_chroma(const float* magnitudes, int bin_count, float* chroma, int sample_rate, int fft_size) {
    if (chroma == NULL || magnitudes == NULL || bin_count <= 0 || fft_size <= 0) return;
    memset(chroma, 0, 12 * sizeof(float));
    float freq_resolution = (float)sample_rate / (float)fft_size;

    for (int bin = 1; bin < bin_count; bin++) {
        float freq = bin * freq_resolution;
        if (freq < CHORD_MIN_FREQ || freq > CHORD_MAX_FREQ) continue;

        float midi = 69.0f + 12.0f * log2f(freq / 440.0f);
        int pitch_class = ((int)roundf(midi) % 12 + 12) % 12;

        // 用高斯加权(越接近中心频率权重越高)
        float deviation = fabsf(midi - roundf(midi));
        float weight = expf(-0.5f * deviation * deviation / 0.5f);

        chroma[pitch_class] += magnitudes[bin] * weight;
    }

    // 归一化
    float max_val = 0.0f;
    for (int i = 0; i < 12; i++) {
        if (chroma[i] > max_val) max_val = chroma[i];
    }
    if (max_val > 0.0f) {
        for (int i = 0; i < 12; i++) chroma[i] /= max_val;
    }
}

// 和弦模板匹配
ChordResult match_chord_from_chroma(const float* chroma) {
    ChordResult result;
    memset(&result, 0, sizeof(ChordResult));
    if (chroma == NULL) return result;

    float best_score = -1.0f;
    int best_root = 0;
    int best_quality = 0;

    // 遍历所有根音和类型
    for (int root = 0; root < 12; root++) {
        for (int quality = 0; quality < 19; quality++) {
            int interval_count = CHORD_INTERVAL_COUNT[quality];

            // 构成音能量
            float positive = 0.0f;
            for (int i = 0; i < interval_count; i++) {
                positive += chroma[(root + CHORD_INTERVALS[quality][i]) % 12];
            }

            // 非构成音能量(惩罚项)
            float negative = 0.0f;
            for (int i = 0; i < 12; i++) {
                if (!is_chord_tone(root, quality, i)) {
                    negative += chroma[i];
                }
            }

            // 归一化到 0..1:完美匹配 = 1,纯噪声 = 0
            float score = (positive - 0.5f * negative) / (float)interval_count;
            if (score < 0.0f) score = 0.0f;
            if (score > 1.0f) score = 1.0f;

            if (score > best_score) {
                best_score = score;
                best_root = root;
                best_quality = quality;
            }
        }
    }

    // 低音检测:在和弦音中取 chroma 最强的一个。
    // 注意:chroma 丢失了八度信息,这里只能给出"最可能的低音音级",
    // 无法可靠区分原位与转位。
    int bass = best_root;
    float bass_val = chroma[best_root];
    for (int i = 0; i < 12; i++) {
        if (!is_chord_tone(best_root, best_quality, i)) continue;
        if (chroma[i] > bass_val) {
            bass_val = chroma[i];
            bass = i;
        }
    }

    result.root_index = best_root;
    result.quality_index = best_quality;
    result.bass_index = bass;
    result.confidence = best_score;

    // 复制 chroma 和检测到的音
    memcpy(result.chroma, chroma, 12 * sizeof(float));
    for (int i = 0; i < 12; i++) {
        result.detected_notes[i] = chroma[i];
    }

    return result;
}

// HPS (Harmonic Product Spectrum) 多音高检测
void detect_multiple_pitches(const float* samples, int sample_count, int sample_rate, MultiPitchResult* out) {
    if (out == NULL) return;
    memset(out, 0, sizeof(MultiPitchResult));
    if (samples == NULL || sample_count <= 0) return;

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

    // 计算幅度谱
    int bin_count = fft_size / 2;
    float* mags = (float*)malloc((size_t)bin_count * sizeof(float));
    if (!mags) {
        free(real); free(imag); free(window);
        return;
    }
    for (int i = 0; i < bin_count; i++) {
        mags[i] = sqrtf(real[i] * real[i] + imag[i] * imag[i]);
    }

    // HPS:只在 i * HPS_HARMONICS < bin_count 的范围内有定义,
    // 范围外的 bin 置零,避免把未参与乘积的原始幅度当成 HPS 值。
    int hps_len = bin_count / HPS_HARMONICS;
    float* hps = (float*)calloc((size_t)bin_count, sizeof(float));
    if (!hps) {
        free(real); free(imag); free(window); free(mags);
        return;
    }
    for (int i = 0; i < hps_len; i++) {
        float v = mags[i];
        for (int h = 2; h <= HPS_HARMONICS; h++) {
            v *= mags[i * h];
        }
        hps[i] = v;
    }

    // 找 HPS 峰值
    float freq_resolution = (float)sample_rate / (float)fft_size;
    int min_bin = (int)(CHORD_MIN_FREQ / freq_resolution);
    int max_bin = (int)(CHORD_MAX_FREQ / freq_resolution);
    if (min_bin < 1) min_bin = 1;
    if (max_bin >= hps_len) max_bin = hps_len - 1;
    if (max_bin < min_bin) max_bin = min_bin;

    int found = 0;
    for (int iter = 0; iter < 12; iter++) {
        // 找当前最大值
        int best_bin = -1;
        float best_val = 0.0f;
        for (int i = min_bin; i <= max_bin; i++) {
            if (hps[i] > best_val) {
                best_val = hps[i];
                best_bin = i;
            }
        }
        if (best_bin < 0 || best_val < 1e-6f) break;

        float freq = best_bin * freq_resolution;
        out->frequencies[found] = freq;
        out->intensities[found] = best_val;
        found++;

        // 抑制该峰附近(范围与频率成正比,约 ±1.3 个半音)
        int suppress = (int)(best_bin * 0.08f) + 2;
        for (int i = best_bin - suppress; i <= best_bin + suppress; i++) {
            if (i >= 0 && i < bin_count) hps[i] = 0;
        }
    }

    out->count = found;

    free(real);
    free(imag);
    free(window);
    free(mags);
    free(hps);
}
