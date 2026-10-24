import 'package:flutter_test/flutter_test.dart';
import 'package:music_helper/domain/note.dart';
import 'package:music_helper/providers/audio_provider.dart';

void main() {
  group('TunerState', () {
    test('默认状态', () {
      const state = TunerState();
      expect(state.frequency, 0);
      expect(state.note, isNull);
      expect(state.centsDeviation, 0);
      expect(state.isActive, isFalse);
    });

    test('copyWith 保留未提供的字段', () {
      const state = TunerState(
        frequency: 440,
        note: MusicalNote(NoteName.a, 4),
        centsDeviation: 3.5,
        isActive: true,
      );
      final updated = state.copyWith(frequency: 445);
      expect(updated.frequency, 445);
      expect(updated.note, const MusicalNote(NoteName.a, 4));
      expect(updated.centsDeviation, 3.5);
      expect(updated.isActive, isTrue);
    });

    test('copyWith 可以显式把 note 置空(信号丢失时清空显示)', () {
      const state = TunerState(
        frequency: 440,
        note: MusicalNote(NoteName.a, 4),
        isActive: true,
      );
      final cleared = state.copyWith(note: null);
      expect(cleared.note, isNull);
      expect(cleared.frequency, 440); // 其他字段保留
    });
  });

  group('ChordState', () {
    test('默认状态', () {
      const state = ChordState();
      expect(state.result, isNull);
      expect(state.isActive, isFalse);
    });

    test('copyWith 可以显式把 result 置空', () {
      const state = ChordState(isActive: true);
      final cleared = state.copyWith(result: null);
      expect(cleared.result, isNull);
      expect(cleared.isActive, isTrue);
    });
  });
}
