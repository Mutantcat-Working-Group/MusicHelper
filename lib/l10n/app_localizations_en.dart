// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Music Helper';

  @override
  String get tab_tuner => 'Tuner';

  @override
  String get tab_chord => 'Chord';

  @override
  String get tab_settings => 'Settings';

  @override
  String get string_label => 'String';

  @override
  String get tolerance_label => 'Tolerance';

  @override
  String get tolerance_desc => 'Cents range for in-tune detection';

  @override
  String get language_label => 'Language';

  @override
  String get custom_tuning_label => 'Custom Tunings';

  @override
  String get no_custom_tunings => 'No custom tunings yet';

  @override
  String get add_custom_tuning => 'Add Custom Tuning';

  @override
  String get tuning_name => 'Tuning Name';

  @override
  String get string_count => 'String Count';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get about_label => 'About';

  @override
  String get about_desc =>
      'Cross-platform tuner and chord recognition tool with custom tunings and inversion detection.';

  @override
  String get chord_waiting => 'Waiting for audio input...';

  @override
  String get inversion_label => 'Inversion';

  @override
  String get confidence_label => 'Confidence';

  @override
  String get notes_label => 'Notes';

  @override
  String get bass_note => 'Bass';

  @override
  String get chroma_label => 'Chroma Features';

  @override
  String get chord_major => 'Major';

  @override
  String get chord_minor => 'Minor';

  @override
  String get chord_augmented => 'Augmented';

  @override
  String get chord_diminished => 'Diminished';

  @override
  String get chord_dominant7 => 'Dominant 7';

  @override
  String get chord_major7 => 'Major 7';

  @override
  String get chord_minor7 => 'Minor 7';

  @override
  String get chord_minor7b5 => 'Half-Diminished 7';

  @override
  String get chord_diminished7 => 'Diminished 7';

  @override
  String get chord_sus2 => 'Suspended 2';

  @override
  String get chord_sus4 => 'Suspended 4';

  @override
  String get chord_major6 => 'Major 6';

  @override
  String get chord_minor6 => 'Minor 6';

  @override
  String get chord_dominant9 => 'Dominant 9';

  @override
  String get chord_major9 => 'Major 9';

  @override
  String get chord_minor9 => 'Minor 9';

  @override
  String get chord_add9 => 'Add 9';

  @override
  String get chord_minorAdd9 => 'Minor Add 9';

  @override
  String get tuning_standard_guitar => 'Standard Guitar EADGBE';

  @override
  String get tuning_half_step_down => 'Half Step Down EbAbDbGbBbEb';

  @override
  String get tuning_open_d => 'Open D Tuning';

  @override
  String get tuning_open_g => 'Open G Tuning';

  @override
  String get tuning_standard_bass => 'Standard Bass EADG';

  @override
  String get tuning_five_string_bass => '5-String Bass BEADG';

  @override
  String get tuning_standard_ukulele => 'Ukulele GCEA';

  @override
  String get tuning_standard_violin => 'Violin GDAE';

  @override
  String get tuning_standard_cello => 'Cello CGDA';
}
