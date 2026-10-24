cmake_minimum_required(VERSION 3.10)
project(music_helper_dsp C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

# 查找所有源文件
set(DSP_SOURCES
    dsp_bridge.cpp
    mpm.cpp
    chord_detector.cpp
    fft.cpp
)

# 创建共享库
add_library(music_helper_dsp SHARED ${DSP_SOURCES})

# 设置输出名称
set_target_properties(music_helper_dsp PROPERTIES
    PREFIX ""
    OUTPUT_NAME "music_helper_dsp"
)

# 链接数学库
target_link_libraries(music_helper_dsp m)

# DSP 是性能热点(每音频帧执行),即使 debug 构建也开启优化,
# 否则未优化的 O(n^2) 自相关会让调音器明显卡顿。
target_compile_options(music_helper_dsp PRIVATE -O2)
