#ifndef MUSIC_HELPER_CHORD_DETECTOR_H
#define MUSIC_HELPER_CHORD_DETECTOR_H

#include "dsp_bridge.h"

#ifdef __cplusplus
extern "C" {
#endif

// 和弦模板匹配核心：给定 12 维 chroma，返回最佳匹配
ChordResult match_chord_from_chroma(const float* chroma);

// 多音高检测：HPS (Harmonic Product Spectrum) 方法
MultiPitchResult detect_multiple_pitches(const float* samples, int sample_count, int sample_rate);

#ifdef __cplusplus
}
#endif

#endif
