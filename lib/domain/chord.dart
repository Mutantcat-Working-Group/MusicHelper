/// 和弦类型
enum ChordQuality {
  major('maj', 'chord_major'),
  minor('m', 'chord_minor'),
  augmented('aug', 'chord_augmented'),
  diminished('dim', 'chord_diminished'),
  dominant7('7', 'chord_dominant7'),
  major7('maj7', 'chord_major7'),
  minor7('m7', 'chord_minor7'),
  minor7b5('m7♭5', 'chord_minor7b5'),
  diminished7('dim7', 'chord_diminished7'),
  sus2('sus2', 'chord_sus2'),
  sus4('sus4', 'chord_sus4'),
  major6('6', 'chord_major6'),
  minor6('m6', 'chord_minor6'),
  dominant9('9', 'chord_dominant9'),
  major9('maj9', 'chord_major9'),
  minor9('m9', 'chord_minor9'),
  add9('add9', 'chord_add9'),
  minorAdd9('madd9', 'chord_minorAdd9');

  final String symbol;
  final String nameKey;

  const ChordQuality(this.symbol, this.nameKey);

  /// 该类型的音程（半音间隔）
  List<int> get intervals {
    switch (this) {
      case ChordQuality.major:
        return [0, 4, 7];
      case ChordQuality.minor:
        return [0, 3, 7];
      case ChordQuality.augmented:
        return [0, 4, 8];
      case ChordQuality.diminished:
        return [0, 3, 6];
      case ChordQuality.dominant7:
        return [0, 4, 7, 10];
      case ChordQuality.major7:
        return [0, 4, 7, 11];
      case ChordQuality.minor7:
        return [0, 3, 7, 10];
      case ChordQuality.minor7b5:
        return [0, 3, 6, 10];
      case ChordQuality.diminished7:
        return [0, 3, 6, 9];
      case ChordQuality.sus2:
        return [0, 2, 7];
      case ChordQuality.sus4:
        return [0, 5, 7];
      case ChordQuality.major6:
        return [0, 4, 7, 9];
      case ChordQuality.minor6:
        return [0, 3, 7, 9];
      case ChordQuality.dominant9:
        return [0, 4, 7, 10, 14];
      case ChordQuality.major9:
        return [0, 4, 7, 11, 14];
      case ChordQuality.minor9:
        return [0, 3, 7, 10, 14];
      case ChordQuality.add9:
        return [0, 4, 7, 14];
      case ChordQuality.minorAdd9:
        return [0, 3, 7, 14];
    }
  }
}

/// 识别出的和弦
class ChordResult {
  final int rootIndex; // 0-11，C=0
  final ChordQuality quality;
  final int bassIndex; // 低音的 index（用于判断转位）
  final double confidence; // 0.0 - 1.0
  final Map<int, double> detectedNotes; // 检测到的音 -> 强度
  final List<double> chroma; // 12 维 chroma 特征

  const ChordResult({
    required this.rootIndex,
    required this.quality,
    required this.bassIndex,
    required this.confidence,
    required this.detectedNotes,
    required this.chroma,
  });

  /// 是否为转位和弦
  bool get isInversion => bassIndex != rootIndex;

  /// 转位编号（0 = 原位，1 = 第一转位，2 = 第二转位...）
  int get inversionNumber {
    final intervals = quality.intervals;
    final idx = intervals.indexOf((bassIndex - rootIndex + 12) % 12);
    return idx >= 0 ? idx : 0;
  }

  /// 根音名称
  String get rootName {
    const names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    return names[rootIndex];
  }

  /// 完整和弦名称（含转位）
  String get fullName {
    final base = '$rootName${quality.symbol}';
    if (!isInversion) return base;
    const names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    return '$base/${names[bassIndex]}';
  }

  /// 原位和弦名称
  String get baseName => '$rootName${quality.symbol}';

  /// 构成音列表
  List<int> get chordToneIndices {
    final intervals = quality.intervals;
    return intervals.map((i) => (rootIndex + i) % 12).toList();
  }

  /// 低音名称
  String get bassName {
    const names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    return names[bassIndex];
  }
}

/// 检测到的单个音（构成音分析）
class DetectedNote {
  final int pitchClass; // 0-11
  final double frequency;
  final double intensity; // 0.0 - 1.0
  final double centsDeviation;

  const DetectedNote({
    required this.pitchClass,
    required this.frequency,
    required this.intensity,
    required this.centsDeviation,
  });
}
