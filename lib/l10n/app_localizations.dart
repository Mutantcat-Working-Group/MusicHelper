import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @app_title.
  ///
  /// In zh, this message translates to:
  /// **'音乐助手'**
  String get app_title;

  /// No description provided for @tab_tuner.
  ///
  /// In zh, this message translates to:
  /// **'调音器'**
  String get tab_tuner;

  /// No description provided for @tab_chord.
  ///
  /// In zh, this message translates to:
  /// **'和弦识别'**
  String get tab_chord;

  /// No description provided for @tab_settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get tab_settings;

  /// No description provided for @string_label.
  ///
  /// In zh, this message translates to:
  /// **'弦'**
  String get string_label;

  /// No description provided for @tolerance_label.
  ///
  /// In zh, this message translates to:
  /// **'音准容差'**
  String get tolerance_label;

  /// No description provided for @tolerance_desc.
  ///
  /// In zh, this message translates to:
  /// **'设置多少音分范围内算作准确'**
  String get tolerance_desc;

  /// No description provided for @language_label.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language_label;

  /// No description provided for @custom_tuning_label.
  ///
  /// In zh, this message translates to:
  /// **'自定义调弦'**
  String get custom_tuning_label;

  /// No description provided for @no_custom_tunings.
  ///
  /// In zh, this message translates to:
  /// **'暂无自定义调弦'**
  String get no_custom_tunings;

  /// No description provided for @add_custom_tuning.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义调弦'**
  String get add_custom_tuning;

  /// No description provided for @tuning_name.
  ///
  /// In zh, this message translates to:
  /// **'调弦名称'**
  String get tuning_name;

  /// No description provided for @string_count.
  ///
  /// In zh, this message translates to:
  /// **'弦数'**
  String get string_count;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @about_label.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about_label;

  /// No description provided for @about_desc.
  ///
  /// In zh, this message translates to:
  /// **'跨平台调音器与和弦识别工具，支持自定义调弦和转位识别。'**
  String get about_desc;

  /// No description provided for @chord_waiting.
  ///
  /// In zh, this message translates to:
  /// **'等待音频输入...'**
  String get chord_waiting;

  /// No description provided for @inversion_label.
  ///
  /// In zh, this message translates to:
  /// **'转位'**
  String get inversion_label;

  /// No description provided for @confidence_label.
  ///
  /// In zh, this message translates to:
  /// **'置信度'**
  String get confidence_label;

  /// No description provided for @notes_label.
  ///
  /// In zh, this message translates to:
  /// **'构成音'**
  String get notes_label;

  /// No description provided for @detected_notes_label.
  ///
  /// In zh, this message translates to:
  /// **'检测到的音'**
  String get detected_notes_label;

  /// No description provided for @bass_note.
  ///
  /// In zh, this message translates to:
  /// **'低音'**
  String get bass_note;

  /// No description provided for @chroma_label.
  ///
  /// In zh, this message translates to:
  /// **'Chroma 特征'**
  String get chroma_label;

  /// No description provided for @chord_major.
  ///
  /// In zh, this message translates to:
  /// **'大三和弦'**
  String get chord_major;

  /// No description provided for @chord_minor.
  ///
  /// In zh, this message translates to:
  /// **'小三和弦'**
  String get chord_minor;

  /// No description provided for @chord_augmented.
  ///
  /// In zh, this message translates to:
  /// **'增三和弦'**
  String get chord_augmented;

  /// No description provided for @chord_diminished.
  ///
  /// In zh, this message translates to:
  /// **'减三和弦'**
  String get chord_diminished;

  /// No description provided for @chord_dominant7.
  ///
  /// In zh, this message translates to:
  /// **'属七和弦'**
  String get chord_dominant7;

  /// No description provided for @chord_major7.
  ///
  /// In zh, this message translates to:
  /// **'大七和弦'**
  String get chord_major7;

  /// No description provided for @chord_minor7.
  ///
  /// In zh, this message translates to:
  /// **'小七和弦'**
  String get chord_minor7;

  /// No description provided for @chord_minor7b5.
  ///
  /// In zh, this message translates to:
  /// **'半减七和弦'**
  String get chord_minor7b5;

  /// No description provided for @chord_diminished7.
  ///
  /// In zh, this message translates to:
  /// **'减七和弦'**
  String get chord_diminished7;

  /// No description provided for @chord_sus2.
  ///
  /// In zh, this message translates to:
  /// **'挂二和弦'**
  String get chord_sus2;

  /// No description provided for @chord_sus4.
  ///
  /// In zh, this message translates to:
  /// **'挂四和弦'**
  String get chord_sus4;

  /// No description provided for @chord_major6.
  ///
  /// In zh, this message translates to:
  /// **'大六和弦'**
  String get chord_major6;

  /// No description provided for @chord_minor6.
  ///
  /// In zh, this message translates to:
  /// **'小六和弦'**
  String get chord_minor6;

  /// No description provided for @chord_dominant9.
  ///
  /// In zh, this message translates to:
  /// **'属九和弦'**
  String get chord_dominant9;

  /// No description provided for @chord_major9.
  ///
  /// In zh, this message translates to:
  /// **'大九和弦'**
  String get chord_major9;

  /// No description provided for @chord_minor9.
  ///
  /// In zh, this message translates to:
  /// **'小九和弦'**
  String get chord_minor9;

  /// No description provided for @chord_add9.
  ///
  /// In zh, this message translates to:
  /// **'加九和弦'**
  String get chord_add9;

  /// No description provided for @chord_minorAdd9.
  ///
  /// In zh, this message translates to:
  /// **'小加九和弦'**
  String get chord_minorAdd9;

  /// No description provided for @tuning_standard_guitar.
  ///
  /// In zh, this message translates to:
  /// **'标准吉他 EADGBE'**
  String get tuning_standard_guitar;

  /// No description provided for @tuning_half_step_down.
  ///
  /// In zh, this message translates to:
  /// **'降半音 EbAbDbGbBbEb'**
  String get tuning_half_step_down;

  /// No description provided for @tuning_open_d.
  ///
  /// In zh, this message translates to:
  /// **'Open D 调弦'**
  String get tuning_open_d;

  /// No description provided for @tuning_open_g.
  ///
  /// In zh, this message translates to:
  /// **'Open G 调弦'**
  String get tuning_open_g;

  /// No description provided for @tuning_standard_bass.
  ///
  /// In zh, this message translates to:
  /// **'标准贝斯 EADG'**
  String get tuning_standard_bass;

  /// No description provided for @tuning_five_string_bass.
  ///
  /// In zh, this message translates to:
  /// **'5弦贝斯 BEADG'**
  String get tuning_five_string_bass;

  /// No description provided for @tuning_standard_ukulele.
  ///
  /// In zh, this message translates to:
  /// **'尤克里里 GCEA'**
  String get tuning_standard_ukulele;

  /// No description provided for @tuning_standard_violin.
  ///
  /// In zh, this message translates to:
  /// **'小提琴 GDAE'**
  String get tuning_standard_violin;

  /// No description provided for @tuning_standard_cello.
  ///
  /// In zh, this message translates to:
  /// **'大提琴 CGDA'**
  String get tuning_standard_cello;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
