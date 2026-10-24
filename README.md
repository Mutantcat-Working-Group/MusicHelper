# music_helper

音乐助手 —— 跨平台调音器与和弦识别工具。

基于 Flutter + Riverpod,录音经 `record` 采集后送入原生 C++ DSP 库
(MPM 音高检测、HPS 多音高检测、chroma 和弦识别),DSP 在独立 isolate 中
运行以避免阻塞 UI 线程。

## 平台支持

| 平台 | 原生库接入方式 |
| --- | --- |
| Android | `android/app/build.gradle.kts` 的 `externalNativeBuild` 直接编译 `native/dsp/CMakeLists.txt` |
| iOS | 根目录 `MusicHelperDSP.podspec` + `ios/Podfile` 中的 `pod 'MusicHelperDSP'`,借助 `use_frameworks!` 编成动态框架,由 `DynamicLibrary.process()` 解析符号 |

原生库缺失时 App 会降级为空结果而不崩溃。

## 开发

```bash
flutter pub get
flutter analyze
flutter test

# 重新生成应用图标(源文件为根目录 icon.png)
dart run flutter_launcher_icons
```

## License

本项目采用 [GNU General Public License v3.0](LICENSE) 授权。

Copyright (C) 2026 Mutantcat

