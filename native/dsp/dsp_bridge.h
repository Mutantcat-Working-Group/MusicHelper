#ifndef MUSIC_HELPER_DSP_BRIDGE_H
#define MUSIC_HELPER_DSP_BRIDGE_H

#include <stdint.h>

// 分析帧长度(2 的幂)。
// 取 8192 而非 4096:低频时 FFT 主瓣宽度(±2 bin)会超过一个半音,
// 导致 chroma 能量泄漏到相邻音级、置信度被惩罚项压低。
// 8192 @ 44.1kHz = 186ms 窗口,对持续和弦足够,FFT 开销可忽略。
#define DSP_FFT_SIZE 8192

#ifdef __cplusplus
extern "C" {
#endif

// MPM 音高检测:返回频率(Hz),0 表示未检测到
float mpm_detect_pitch(const float* samples, int sample_count, int sample_rate);

// 多音高检测:结果写入调用方提供的 out(不转移内存所有权)
typedef struct {
    float frequencies[12];
    float intensities[12];
    int count;
} MultiPitchResult;

void detect_multiple_pitches(const float* samples, int sample_count, int sample_rate, MultiPitchResult* out);

// 和弦检测:结果写入调用方提供的 out(不转移内存所有权)
typedef struct {
    int root_index;      // 0-11
    int quality_index;   // 0-18
    int bass_index;      // 0-11
    float confidence;    // 0.0 - 1.0
    float chroma[12];    // 12 维 chroma 特征
    float detected_notes[12]; // 每个 pitch class 的强度
} ChordResult;

void detect_chord(const float* samples, int sample_count, int sample_rate, ChordResult* out);

// 初始化(记录采样率)。重复调用是安全的。
void dsp_init(int sample_rate);

// 释放全局资源
void dsp_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif // MUSIC_HELPER_DSP_BRIDGE_H
