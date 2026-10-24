/// 音频配置
class AudioConfig {
  static const int sampleRate = 44100;

  /// MPM 音高检测窗口(4096 @ 44.1kHz ≈ 93ms,兼顾响应速度与低频分辨率)
  static const int pitchWindowSize = 4096;

  /// 和弦检测窗口(8192 @ 44.1kHz ≈ 186ms)。
  /// 比音高窗口长一倍:低频时 FFT 主瓣宽度会超过一个半音,
  /// 窗口太短会导致 chroma 能量泄漏、置信度被压低。
  static const int chordWindowSize = 8192;

  /// 分析步进(每积累这么多个新样本就分析一次,50% 重叠)
  static const int hopSize = 2048;

  // 调音器频率范围
  static const double minFrequency = 20.0;
  static const double maxFrequency = 5000.0;

  // 和弦识别频率范围
  static const double chordMinFrequency = 50.0;
  static const double chordMaxFrequency = 5000.0;
}
