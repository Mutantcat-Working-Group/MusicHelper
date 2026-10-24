import 'package:flutter_test/flutter_test.dart';
import 'package:music_helper/domain/note.dart';
import 'package:music_helper/domain/tuning.dart';

void main() {
  group('Tuning 预设', () {
    test('标准吉他为 EADGBE(从低音弦到高音弦)', () {
      final tuning = Tuning.standardGuitar();
      expect(tuning.id, 'standard_guitar');
      expect(tuning.strings.length, 6);
      expect(tuning.strings.first, const MusicalNote(NoteName.e, 2));
      expect(tuning.strings.last, const MusicalNote(NoteName.e, 4));
      expect(tuning.strings.map((n) => n.name.label).join(),
          'EADGBE'.split('').join());
    });

    test('标准贝斯为 EADG', () {
      final tuning = Tuning.standardBass();
      expect(tuning.strings.length, 4);
      expect(tuning.strings.first, const MusicalNote(NoteName.e, 1));
      expect(tuning.strings.last, const MusicalNote(NoteName.g, 2));
    });

    test('5 弦贝斯最低音为 B0', () {
      final tuning = Tuning.fiveStringBass();
      expect(tuning.strings.length, 5);
      expect(tuning.strings.first, const MusicalNote(NoteName.b, 0));
    });

    test('所有预设 id 唯一且都是预设', () {
      final presets = Tuning.allPresets();
      expect(presets.length, 9);
      expect(presets.map((t) => t.id).toSet().length, presets.length);
      expect(presets.every((t) => t.isPreset), isTrue);
    });

    test('除尤克里里外,预设的弦按从低到高排列', () {
      // 尤克里里是 reentrant(高音 G)调弦:第 4 弦 G4 高于第 3 弦 C4,
      // 属于物理弦序而非音高顺序,因此不参与该检查。
      for (final tuning in Tuning.allPresets()) {
        if (tuning.id == 'standard_ukulele') continue;
        for (var i = 1; i < tuning.strings.length; i++) {
          expect(tuning.strings[i].midiNumber,
              greaterThan(tuning.strings[i - 1].midiNumber),
              reason: '${tuning.id} 第 ${i + 1} 弦不高于第 $i 弦');
        }
      }
    });

    test('尤克里里为 reentrant 调弦 GCEA', () {
      final tuning = Tuning.standardUkulele();
      expect(tuning.strings.map((n) => n.displayName).toList(),
          ['G4', 'C4', 'E4', 'A4']);
      // 第 4 弦 G4 高于第 3 弦 C4(reentrant 的特征)
      expect(tuning.strings[0].midiNumber, greaterThan(tuning.strings[1].midiNumber));
    });
  });

  group('Tuning 序列化', () {
    test('所有预设 JSON 往返一致', () {
      for (final tuning in Tuning.allPresets()) {
        final restored = Tuning.fromJson(tuning.toJson());
        expect(restored.id, tuning.id);
        expect(restored.nameKey, tuning.nameKey);
        expect(restored.strings, tuning.strings);
        expect(restored.isPreset, tuning.isPreset);
      }
    });

    test('自定义调弦 JSON 往返一致', () {
      const custom = Tuning(
        id: 'custom_test',
        nameKey: 'My Tuning',
        strings: [
          MusicalNote(NoteName.d, 2),
          MusicalNote(NoteName.a, 3),
        ],
        isPreset: false,
      );
      final restored = Tuning.fromJson(custom.toJson());
      expect(restored.id, 'custom_test');
      expect(restored.nameKey, 'My Tuning');
      expect(restored.strings, custom.strings);
      expect(restored.isPreset, isFalse);
    });

    test('缺省 isPreset 时按自定义处理', () {
      final restored = Tuning.fromJson({
        'id': 'x',
        'nameKey': 'x',
        'strings': [
          {'name': 0, 'octave': 4}
        ],
      });
      expect(restored.isPreset, isFalse);
    });
  });

  group('Tuning 相等性', () {
    test('按 id 判等', () {
      expect(Tuning.standardGuitar(), Tuning.standardGuitar());
      expect(Tuning.standardGuitar(), isNot(Tuning.standardBass()));
      expect(Tuning.standardGuitar().hashCode, Tuning.standardGuitar().hashCode);
    });
  });
}
