import 'package:flutter_test/flutter_test.dart';
import 'package:music_helper/domain/chord.dart';

void main() {
  group('ChordQuality', () {
    test('大三和弦音程为 0/4/7', () {
      expect(ChordQuality.major.intervals, [0, 4, 7]);
    });

    test('小三和弦音程为 0/3/7', () {
      expect(ChordQuality.minor.intervals, [0, 3, 7]);
    });

    test('所有音程从 0 开始且严格递增', () {
      for (final quality in ChordQuality.values) {
        expect(quality.intervals.first, 0, reason: quality.name);
        for (var i = 1; i < quality.intervals.length; i++) {
          expect(quality.intervals[i], greaterThan(quality.intervals[i - 1]),
              reason: '${quality.name} 第 $i 个音程未递增');
        }
      }
    });

    test('每个类型都有符号和 i18n key', () {
      for (final quality in ChordQuality.values) {
        expect(quality.symbol, isNotEmpty);
        expect(quality.nameKey, startsWith('chord_'));
      }
    });
  });

  group('ChordResult', () {
    ChordResult makeChord(int root, ChordQuality quality, int bass) => ChordResult(
          rootIndex: root,
          quality: quality,
          bassIndex: bass,
          confidence: 0.9,
          detectedNotes: const {},
          chroma: List.filled(12, 0),
        );

    test('原位判断', () {
      expect(makeChord(0, ChordQuality.major, 0).isInversion, isFalse);
      expect(makeChord(0, ChordQuality.major, 4).isInversion, isTrue);
    });

    test('第一转位:Cmaj/E', () {
      final chord = makeChord(0, ChordQuality.major, 4);
      expect(chord.inversionNumber, 1);
      expect(chord.fullName, 'Cmaj/E');
      expect(chord.baseName, 'Cmaj');
    });

    test('第二转位:Cmaj/G', () {
      final chord = makeChord(0, ChordQuality.major, 7);
      expect(chord.inversionNumber, 2);
      expect(chord.fullName, 'Cmaj/G');
    });

    test('构成音计算(含跨八度回绕)', () {
      expect(makeChord(0, ChordQuality.major, 0).chordToneIndices, [0, 4, 7]);
      // A 小三:A(9) C(0) E(4)
      expect(makeChord(9, ChordQuality.minor, 9).chordToneIndices, [9, 0, 4]);
    });

    test('根音名与低音名', () {
      expect(makeChord(0, ChordQuality.major, 0).rootName, 'C');
      expect(makeChord(9, ChordQuality.minor, 9).rootName, 'A');
      expect(makeChord(0, ChordQuality.major, 7).bassName, 'G');
    });

    test('低音不属于该和弦时转位编号回退为 0', () {
      // 低音 C# 不在 C 大调三和弦里
      expect(makeChord(0, ChordQuality.major, 1).inversionNumber, 0);
    });
  });

  group('DetectedNote', () {
    test('字段完整', () {
      const note = DetectedNote(
        pitchClass: 7,
        frequency: 392.0,
        intensity: 0.85,
        centsDeviation: -3.2,
      );
      expect(note.pitchClass, 7);
      expect(note.frequency, 392.0);
      expect(note.intensity, 0.85);
      expect(note.centsDeviation, -3.2);
    });
  });
}
