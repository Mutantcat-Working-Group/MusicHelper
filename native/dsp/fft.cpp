#include "fft.h"
#include <string.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// 迭代基-2 FFT（Cooley-Tukey）
void fft(float* real, float* imag, int n) {
    // 位反转
    for (int i = 1, j = 0; i < n; i++) {
        int bit = n >> 1;
        for (; j & bit; bit >>= 1) {
            j ^= bit;
        }
        j ^= bit;
        if (i < j) {
            float tr = real[i]; real[i] = real[j]; real[j] = tr;
            float ti = imag[i]; imag[i] = imag[j]; imag[j] = ti;
        }
    }

    // FFT
    for (int len = 2; len <= n; len <<= 1) {
        float ang = -2.0f * M_PI / (float)len;
        float wre = cosf(ang), wim = sinf(ang);
        for (int i = 0; i < n; i += len) {
            float curRe = 1.0f, curIm = 0.0f;
            for (int j = 0; j < len / 2; j++) {
                float ur = real[i + j], ui = imag[i + j];
                float vr = real[i + j + len / 2] * curRe - imag[i + j + len / 2] * curIm;
                float vi = real[i + j + len / 2] * curIm + imag[i + j + len / 2] * curRe;
                real[i + j] = ur + vr;
                imag[i + j] = ui + vi;
                real[i + j + len / 2] = ur - vr;
                imag[i + j + len / 2] = ui - vi;
                float newRe = curRe * wre - curIm * wim;
                float newIm = curRe * wim + curIm * wre;
                curRe = newRe;
                curIm = newIm;
            }
        }
    }
}

// 汉宁窗
void hann_window(float* output, int n) {
    for (int i = 0; i < n; i++) {
        output[i] = 0.5f * (1.0f - cosf(2.0f * M_PI * (float)i / (float)(n - 1)));
    }
}
