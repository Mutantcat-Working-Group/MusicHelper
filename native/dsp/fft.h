#ifndef MUSIC_HELPER_FFT_H
#define MUSIC_HELPER_FFT_H

#ifdef __cplusplus
extern "C" {
#endif

// 迭代基-2 FFT(Cooley-Tukey)。n 必须是 2 的幂。
void fft(float* real, float* imag, int n);

// 汉宁窗。n <= 1 时退化为全 1。
void hann_window(float* output, int n);

// 把任意长度的采样整理成长度 fft_size(2 的幂)的分析帧:
// 样本不足时末尾补零,超出时取最新的一段(对实时流更有意义)。
void prepare_analysis_frame(const float* samples, int sample_count, int fft_size, float* out);

#ifdef __cplusplus
}
#endif

#endif
