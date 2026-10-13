// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get app_title => '音乐助手';

  @override
  String get tab_tuner => '调音器';

  @override
  String get tab_chord => '和弦识别';

  @override
  String get tab_settings => '设置';

  @override
  String get string_label => '弦';

  @override
  String get tolerance_label => '音准容差';

  @override
  String get tolerance_desc => '设置多少音分范围内算作准确';

  @override
  String get language_label => '语言';

  @override
  String get custom_tuning_label => '自定义调弦';

  @override
  String get no_custom_tunings => '暂无自定义调弦';

  @override
  String get add_custom_tuning => '添加自定义调弦';

  @override
  String get tuning_name => '调弦名称';

  @override
  String get string_count => '弦数';

  @override
  String get cancel => '取消';

  @override
  String get add => '添加';

  @override
  String get about_label => '关于';

  @override
  String get about_desc => '跨平台调音器与和弦识别工具，支持自定义调弦和转位识别。';

  @override
  String get chord_waiting => '等待音频输入...';

  @override
  String get inversion_label => '转位';

  @override
  String get confidence_label => '置信度';

  @override
  String get notes_label => '构成音';

  @override
  String get bass_note => '低音';

  @override
  String get chroma_label => 'Chroma 特征';

  @override
  String get chord_major => '大三和弦';

  @override
  String get chord_minor => '小三和弦';

  @override
  String get chord_augmented => '增三和弦';

  @override
  String get chord_diminished => '减三和弦';

  @override
  String get chord_dominant7 => '属七和弦';

  @override
  String get chord_major7 => '大七和弦';

  @override
  String get chord_minor7 => '小七和弦';

  @override
  String get chord_minor7b5 => '半减七和弦';

  @override
  String get chord_diminished7 => '减七和弦';

  @override
  String get chord_sus2 => '挂二和弦';

  @override
  String get chord_sus4 => '挂四和弦';

  @override
  String get chord_major6 => '大六和弦';

  @override
  String get chord_minor6 => '小六和弦';

  @override
  String get chord_dominant9 => '属九和弦';

  @override
  String get chord_major9 => '大九和弦';

  @override
  String get chord_minor9 => '小九和弦';

  @override
  String get chord_add9 => '加九和弦';

  @override
  String get chord_minorAdd9 => '小加九和弦';

  @override
  String get tuning_standard_guitar => '标准吉他 EADGBE';

  @override
  String get tuning_half_step_down => '降半音 EbAbDbGbBbEb';

  @override
  String get tuning_open_d => 'Open D 调弦';

  @override
  String get tuning_open_g => 'Open G 调弦';

  @override
  String get tuning_standard_bass => '标准贝斯 EADG';

  @override
  String get tuning_five_string_bass => '5弦贝斯 BEADG';

  @override
  String get tuning_standard_ukulele => '尤克里里 GCEA';

  @override
  String get tuning_standard_violin => '小提琴 GDAE';

  @override
  String get tuning_standard_cello => '大提琴 CGDA';
}
