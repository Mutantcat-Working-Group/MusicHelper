#ifndef MUSIC_HELPER_MPM_H
#define MUSIC_HELPER_MPM_H

#ifdef __cplusplus
extern "C" {
#endif

void mpm_init(int sample_rate);
float mpm_detect_pitch(const float* samples, int sample_count, int sample_rate);

#ifdef __cplusplus
}
#endif

#endif
