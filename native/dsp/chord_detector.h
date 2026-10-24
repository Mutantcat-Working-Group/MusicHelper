#ifndef MUSIC_HELPER_CHORD_DETECTOR_H
#define MUSIC_HELPER_CHORD_DETECTOR_H

#include "dsp_bridge.h"

#ifdef __cplusplus
extern "C" {
#endif

// 计算 12 维 chroma 特征(从 FFT 幅度谱)。
// magnitudes: 长度 bin_count 的幅度谱;chroma: 长度 12 的输出(已归一化到最大值 1)。
void compute_chroma(const float* magnitudes, int bin_count, float* chroma, int sample_rate, int fft_size);

// 和弦模板匹配核心:给定 12 维 chroma,返回最佳匹配。
ChordResult match_chord_from_chroma(const float* chroma);

// 多音高检测:HPS (Harmonic Product Spectrum) 方法。
// 结果写入调用方提供的 out(不转移内存所有权)。
void detect_multiple_pitches(const float* samples, int sample_count, int sample_rate, MultiPitchResult* out);

#ifdef __cplusplus
}
#endif

#endif
