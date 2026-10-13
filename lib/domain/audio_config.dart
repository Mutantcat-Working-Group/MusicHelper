/// 音频配置
class AudioConfig {
  static const int sampleRate = 44100;
  static const int bufferSize = 2048;
  static const int fftSize = 4096;
  static const int overlap = 4;

  // 调音器频率范围
  static const double minFrequency = 20.0;
  static const double maxFrequency = 5000.0;

  // 和弦识别频率范围
  static const double chordMinFrequency = 50.0;
  static const double chordMaxFrequency = 5000.0;
}
