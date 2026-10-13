#ifndef MUSIC_HELPER_DSP_BRIDGE_H
#define MUSIC_HELPER_DSP_BRIDGE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// MPM 音高检测：返回频率（Hz），0 表示未检测到
float mpm_detect_pitch(const float* samples, int sample_count, int sample_rate);

// 多音高检测：返回检测到的频率数组和数量
typedef struct {
    float frequencies[12];
    float intensities[12];
    int count;
} MultiPitchResult;

MultiPitchResult detect_multiple_pitches(const float* samples, int sample_count, int sample_rate);

// 和弦检测
typedef struct {
    int root_index;      // 0-11
    int quality_index;   // 0-18
    int bass_index;      // 0-11
    float confidence;    // 0.0 - 1.0
    float chroma[12];    // 12 维 chroma 特征
    float detected_notes[12]; // 每个 pitch class 的强度
} ChordResult;

ChordResult detect_chord(const float* samples, int sample_count, int sample_rate);

// 初始化（分配全局工作缓冲区）
void dsp_init(int sample_rate);
void dsp_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif // MUSIC_HELPER_DSP_BRIDGE_H
