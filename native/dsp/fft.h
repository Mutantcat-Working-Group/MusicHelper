#ifndef MUSIC_HELPER_FFT_H
#define MUSIC_HELPER_FFT_H

#ifdef __cplusplus
extern "C" {
#endif

void fft(float* real, float* imag, int n);
void hann_window(float* output, int n);

#ifdef __cplusplus
}
#endif

#endif
