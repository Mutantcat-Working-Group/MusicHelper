import 'note.dart';

/// 调弦（一组弦的音高定义）
class Tuning {
  final String id;
  final String nameKey; // i18n key
  final List<MusicalNote> strings; // 从低音弦到高音弦
  final bool isPreset;

  const Tuning({
    required this.id,
    required this.nameKey,
    required this.strings,
    this.isPreset = true,
  });

  /// 标准吉他调弦 EADGBE
  static Tuning standardGuitar() => const Tuning(
        id: 'standard_guitar',
        nameKey: 'tuning_standard_guitar',
        strings: [
          MusicalNote(NoteName.e, 2),
          MusicalNote(NoteName.a, 2),
          MusicalNote(NoteName.d, 3),
          MusicalNote(NoteName.g, 3),
          MusicalNote(NoteName.b, 3),
          MusicalNote(NoteName.e, 4),
        ],
      );

  /// 降半音吉他调弦
  static Tuning halfStepDownGuitar() => const Tuning(
        id: 'half_step_down',
        nameKey: 'tuning_half_step_down',
        strings: [
          MusicalNote(NoteName.dSharp, 2),
          MusicalNote(NoteName.gSharp, 2),
          MusicalNote(NoteName.cSharp, 3),
          MusicalNote(NoteName.fSharp, 3),
          MusicalNote(NoteName.aSharp, 3),
          MusicalNote(NoteName.dSharp, 4),
        ],
      );

  /// Open D 调弦
  static Tuning openDGuitar() => const Tuning(
        id: 'open_d',
        nameKey: 'tuning_open_d',
        strings: [
          MusicalNote(NoteName.d, 2),
          MusicalNote(NoteName.a, 2),
          MusicalNote(NoteName.d, 3),
          MusicalNote(NoteName.fSharp, 3),
          MusicalNote(NoteName.a, 3),
          MusicalNote(NoteName.d, 4),
        ],
      );

  /// Open G 调弦
  static Tuning openGGuitar() => const Tuning(
        id: 'open_g',
        nameKey: 'tuning_open_g',
        strings: [
          MusicalNote(NoteName.d, 2),
          MusicalNote(NoteName.g, 2),
          MusicalNote(NoteName.d, 3),
          MusicalNote(NoteName.g, 3),
          MusicalNote(NoteName.b, 3),
          MusicalNote(NoteName.d, 4),
        ],
      );

  /// 标准贝斯调弦 (4弦)
  static Tuning standardBass() => const Tuning(
        id: 'standard_bass',
        nameKey: 'tuning_standard_bass',
        strings: [
          MusicalNote(NoteName.e, 1),
          MusicalNote(NoteName.a, 1),
          MusicalNote(NoteName.d, 2),
          MusicalNote(NoteName.g, 2),
        ],
      );

  /// 5弦贝斯调弦
  static Tuning fiveStringBass() => const Tuning(
        id: 'five_string_bass',
        nameKey: 'tuning_five_string_bass',
        strings: [
          MusicalNote(NoteName.b, 0),
          MusicalNote(NoteName.e, 1),
          MusicalNote(NoteName.a, 1),
          MusicalNote(NoteName.d, 2),
          MusicalNote(NoteName.g, 2),
        ],
      );

  /// 尤克里里标准调弦 GCEA
  static Tuning standardUkulele() => const Tuning(
        id: 'standard_ukulele',
        nameKey: 'tuning_standard_ukulele',
        strings: [
          MusicalNote(NoteName.g, 4),
          MusicalNote(NoteName.c, 4),
          MusicalNote(NoteName.e, 4),
          MusicalNote(NoteName.a, 4),
        ],
      );

  /// 小提琴标准调弦 GDAE
  static Tuning standardViolin() => const Tuning(
        id: 'standard_violin',
        nameKey: 'tuning_standard_violin',
        strings: [
          MusicalNote(NoteName.g, 3),
          MusicalNote(NoteName.d, 4),
          MusicalNote(NoteName.a, 4),
          MusicalNote(NoteName.e, 5),
        ],
      );

  /// 大提琴标准调弦 CGDA
  static Tuning standardCello() => const Tuning(
        id: 'standard_cello',
        nameKey: 'tuning_standard_cello',
        strings: [
          MusicalNote(NoteName.c, 2),
          MusicalNote(NoteName.g, 2),
          MusicalNote(NoteName.d, 3),
          MusicalNote(NoteName.a, 3),
        ],
      );

  /// 所有预设调弦
  static List<Tuning> allPresets() => [
        standardGuitar(),
        halfStepDownGuitar(),
        openDGuitar(),
        openGGuitar(),
        standardBass(),
        fiveStringBass(),
        standardUkulele(),
        standardViolin(),
        standardCello(),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameKey': nameKey,
        'strings': strings
            .map((n) => {'name': n.name.index, 'octave': n.octave})
            .toList(),
        'isPreset': isPreset,
      };

  factory Tuning.fromJson(Map<String, dynamic> json) => Tuning(
        id: json['id'] as String,
        nameKey: json['nameKey'] as String,
        strings: (json['strings'] as List)
            .map((s) => MusicalNote(
                  NoteName.fromIndex(s['name'] as int),
                  s['octave'] as int,
                ))
            .toList(),
        isPreset: json['isPreset'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Tuning && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
