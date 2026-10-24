import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:music_helper/domain/note.dart';

void main() {
  group('MusicalNote', () {
    test('A4 标准频率为 440Hz', () {
      expect(const MusicalNote(NoteName.a, 4).frequency, closeTo(440.0, 0.001));
    });

    test('C4 是中央 C,MIDI 60', () {
      final c4 = const MusicalNote(NoteName.c, 4);
      expect(c4.midiNumber, 60);
      expect(c4.frequency, closeTo(261.6256, 0.001));
    });

    test('fromFrequency 与频率往返一致', () {
      final notes = [
        const MusicalNote(NoteName.e, 2), // 吉他 6 弦
        const MusicalNote(NoteName.a, 2), // 吉他 5 弦
        const MusicalNote(NoteName.g, 3), // 吉他 3 弦
        const MusicalNote(NoteName.b, 0), // 5 弦贝斯最低音
        const MusicalNote(NoteName.e, 4), // 吉他 1 弦
      ];
      for (final note in notes) {
        expect(MusicalNote.fromFrequency(note.frequency), note,
            reason: '${note.displayName} 往返失败');
      }
    });

    test('centsDeviation 对标准音为 0,偏高为正偏低为负', () {
      final a4 = const MusicalNote(NoteName.a, 4);
      expect(a4.centsDeviation(440.0), closeTo(0, 0.001));
      // 音分是对数单位:445Hz 偏高 19.56 音分,435Hz 偏低 19.79 音分
      expect(a4.centsDeviation(445.0), closeTo(19.56, 0.1));
      expect(a4.centsDeviation(435.0), closeTo(-19.79, 0.1));
    });

    test('centsDeviation 是相对最近半音的偏差,范围 ±50 音分', () {
      final a4 = const MusicalNote(NoteName.a, 4);
      // 880Hz 正好是 A5,音高完全准确,偏差为 0(不是 1200)
      expect(a4.centsDeviation(880.0), closeTo(0, 0.001));
      // 落在两个半音正中间时偏差达到 ±50 的极值
      final halfway = 440.0 * math.pow(2, 0.5 / 12);
      expect(a4.centsDeviation(halfway), closeTo(-50, 0.1));
    });

    test('非法频率不崩溃', () {
      expect(MusicalNote.fromFrequency(0), const MusicalNote(NoteName.c, 4));
      expect(MusicalNote.fromFrequency(-100), const MusicalNote(NoteName.c, 4));
      expect(const MusicalNote(NoteName.a, 4).centsDeviation(0), 0);
      expect(const MusicalNote(NoteName.a, 4).centsDeviation(-1), 0);
    });

    test('相等性与 hashCode', () {
      expect(const MusicalNote(NoteName.c, 4), const MusicalNote(NoteName.c, 4));
      expect(const MusicalNote(NoteName.c, 4), isNot(const MusicalNote(NoteName.c, 5)));
      expect(const MusicalNote(NoteName.c, 4).hashCode,
          const MusicalNote(NoteName.c, 4).hashCode);
    });
  });

  group('NoteName', () {
    test('fromIndex 循环取值', () {
      expect(NoteName.fromIndex(0), NoteName.c);
      expect(NoteName.fromIndex(12), NoteName.c);
      expect(NoteName.fromIndex(13), NoteName.cSharp);
    });

    test('noteIndex 与枚举顺序一致', () {
      for (var i = 0; i < NoteName.values.length; i++) {
        expect(NoteName.values[i].noteIndex, i);
      }
    });
  });
}
