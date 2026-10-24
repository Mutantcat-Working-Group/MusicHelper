#ifndef MUSIC_HELPER_MPM_H
#define MUSIC_HELPER_MPM_H

#ifdef __cplusplus
extern "C" {
#endif

// MPM (McLeod Pitch Method) 音高检测。
// 返回频率(Hz),0 表示未检测到可靠音高。
// 实现要点:在 [sample_rate/MAX_FREQ, sample_rate/MIN_FREQ] 的滞后范围内计算 NSDF,
// 取"阈值以上第一个局部极大"而非最高峰(避免取到周期倍数导致低八度误差)。
float mpm_detect_pitch(const float* samples, int sample_count, int sample_rate);

#ifdef __cplusplus
}
#endif

#endif
