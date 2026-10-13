import 'dart:math' as math;

/// 音高频率（Hz）
typedef Frequency = double;

/// 音分偏差（cents），0 表示完全准
typedef Cents = double;

/// 音名枚举
enum NoteName {
  c('C'),
  cSharp('C#'),
  d('D'),
  dSharp('D#'),
  e('E'),
  f('F'),
  fSharp('F#'),
  g('G'),
  gSharp('G#'),
  a('A'),
  aSharp('A#'),
  b('B');

  final String label;
  const NoteName(this.label);

  static NoteName fromIndex(int index) {
    return NoteName.values[index % 12];
  }

  int get noteIndex => NoteName.values.indexOf(this);

  static NoteName fromMidi(int midi) => fromIndex(midi % 12);
}

/// 一个具体的音（音名 + 八度）
class MusicalNote {
  final NoteName name;
  final int octave;

  const MusicalNote(this.name, this.octave);

  /// MIDI 音符号（C4 = 60）
  int get midiNumber => (octave + 1) * 12 + name.noteIndex;

  /// 标准频率（A4 = 440Hz）
  double get frequency {
    final n = midiNumber - 69;
    return 440.0 * math.pow(2, n / 12).toDouble();
  }

  /// 从频率反推最近的音
  factory MusicalNote.fromFrequency(double freq) {
    if (freq <= 0) return const MusicalNote(NoteName.c, 4);
    final n = 12 * (math.log(freq / 440) / math.ln2) + 69;
    final midi = n.round();
    final octave = (midi ~/ 12) - 1;
    final name = NoteName.fromMidi(midi);
    return MusicalNote(name, octave);
  }

  /// 音分偏差：freq 相对于该音标准频率的偏差
  double centsDeviation(double freq) {
    if (freq <= 0) return 0;
    final n = 12 * (math.log(freq / 440) / math.ln2) + 69;
    final midi = n.round();
    return 100.0 * (n - midi);
  }

  String get displayName => '${name.label}$octave';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicalNote &&
          name == other.name &&
          octave == other.octave;

  @override
  int get hashCode => name.noteIndex ^ (octave << 4);

  @override
  String toString() => displayName;
}
