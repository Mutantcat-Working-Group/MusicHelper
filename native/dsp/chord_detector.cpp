#include "chord_detector.h"
#include "fft.h"
#include <math.h>
#include <string.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// 19 种和弦类型（与 Dart 侧 ChordQuality 对应）
// 0=major, 1=minor, 2=aug, 3=dim, 4=7, 5=maj7, 6=m7, 7=m7b5, 8=dim7,
// 9=sus2, 10=sus4, 11=6, 12=m6, 13=9, 14=maj9, 15=m9, 16=add9, 17=madd9
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
    {0, 4, 7, 14, 0, 0, 0, 0},       // 16: add9
    {0, 3, 7, 14, 0, 0, 0, 0},       // 17: madd9
    {0, 4, 7, 10, 14, 0, 0, 0},      // 18: dom9 (alias)
};

static const int CHORD_INTERVAL_COUNT[19] = {
    3, 3, 3, 3, 4, 4, 4, 4, 4,
    3, 3, 4, 4, 5, 5, 5, 4, 4, 5
};

// 计算 12 维 chroma 特征（从 FFT 频谱）
static void compute_chroma(const float* magnitudes, int bin_count, float* chroma, int sample_rate, int fft_size) {
    memset(chroma, 0, 12 * sizeof(float));
    float freq_resolution = (float)sample_rate / (float)fft_size;

    for (int i = 0; i < 12; i++) chroma[i] = 0.0f;

    for (int bin = 1; bin < bin_count; bin++) {
        float freq = bin * freq_resolution;
        if (freq < 50.0f || freq > 5000.0f) continue;

        float midi = 69.0f + 12.0f * log2f(freq / 440.0f);
        int pitch_class = ((int)roundf(midi) % 12 + 12) % 12;

        // 用高斯加权（越接近中心频率权重越高）
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

    float best_score = -1.0f;
    int best_root = 0;
    int best_quality = 0;

    // 遍历所有根音和类型
    for (int root = 0; root < 12; root++) {
        for (int quality = 0; quality < 19; quality++) {
            float score = 0.0f;
            float total = 0.0f;

            // 匹配和弦音
            int interval_count = CHORD_INTERVAL_COUNT[quality];
            for (int i = 0; i < interval_count; i++) {
                int note_idx = (root + CHORD_INTERVALS[quality][i]) % 12;
                score += chroma[note_idx];
                total += 1.0f;
            }

            // 惩罚非和弦音
            for (int i = 0; i < 12; i++) {
                int is_chord_tone = 0;
                for (int j = 0; j < interval_count; j++) {
                    if ((root + CHORD_INTERVALS[quality][j]) % 12 == i) {
                        is_chord_tone = 1;
                        break;
                    }
                }
                if (!is_chord_tone) {
                    score -= chroma[i] * 0.5f;
                    total += 0.5f;
                }
            }

            score /= total;

            if (score > best_score) {
                best_score = score;
                best_root = root;
                best_quality = quality;
            }
        }
    }

    // 检测低音（chroma 中强度最高的非根音或根音）
    int bass = best_root;
    float bass_val = chroma[best_root];
    for (int i = 0; i < 12; i++) {
        if (i != best_root && chroma[i] > bass_val * 0.3f) {
            // 检查是否是和弦音
            int is_chord_tone = 0;
            int interval_count = CHORD_INTERVAL_COUNT[best_quality];
            for (int j = 0; j < interval_count; j++) {
                if ((best_root + CHORD_INTERVALS[best_quality][j]) % 12 == i) {
                    is_chord_tone = 1;
                    break;
                }
            }
            if (is_chord_tone && chroma[i] > bass_val) {
                bass = i;
                bass_val = chroma[i];
            }
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
MultiPitchResult detect_multiple_pitches(const float* samples, int sample_count, int sample_rate) {
    MultiPitchResult result;
    memset(&result, 0, sizeof(result));

    int fft_size = 4096;
    if (sample_count < fft_size) fft_size = sample_count;

    float* real = (float*)malloc(fft_size * sizeof(float));
    float* imag = (float*)calloc(fft_size, sizeof(float));
    float* windowed = (float*)malloc(fft_size * sizeof(float));
    float* window = (float*)malloc(fft_size * sizeof(float));

    hann_window(window, fft_size);
    for (int i = 0; i < fft_size; i++) {
        windowed[i] = (i < sample_count ? samples[i] : 0.0f) * window[i];
        real[i] = windowed[i];
    }

    fft(real, imag, fft_size);

    // 计算幅度谱
    int bin_count = fft_size / 2;
    float* mags = (float*)malloc(bin_count * sizeof(float));
    for (int i = 0; i < bin_count; i++) {
        mags[i] = sqrtf(real[i] * real[i] + imag[i] * imag[i]);
    }

    // HPS: 下采样并相乘
    float* hps = (float*)malloc(bin_count * sizeof(float));
    memcpy(hps, mags, bin_count * sizeof(float));

    for (int h = 2; h <= 5; h++) {
        int factor = h;
        for (int i = 0; i < bin_count / factor; i++) {
            hps[i] *= mags[i * factor];
        }
    }

    // 找 HPS 峰值
    float freq_resolution = (float)sample_rate / (float)fft_size;
    float min_freq = 50.0f;
    float max_freq = 5000.0f;
    int min_bin = (int)(min_freq / freq_resolution);
    int max_bin = (int)(max_freq / freq_resolution);
    if (max_bin >= bin_count) max_bin = bin_count - 1;

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
        if (best_bin < 0 || best_val < 0.01f) break;

        float freq = best_bin * freq_resolution;
        result.frequencies[found] = freq;
        result.intensities[found] = best_val;
        found++;

        // 抑制该峰附近
        int suppress_range = 3;
        for (int i = best_bin - suppress_range; i <= best_bin + suppress_range; i++) {
            if (i >= 0 && i < bin_count) hps[i] = 0;
        }
    }

    result.count = found;

    free(real);
    free(imag);
    free(windowed);
    free(window);
    free(mags);
    free(hps);

    return result;
}
