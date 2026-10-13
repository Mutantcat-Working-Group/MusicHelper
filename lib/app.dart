import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_helper/l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'package:music_helper/ui/theme/dark_theme.dart';
import 'package:music_helper/ui/home_page.dart';

class MusicHelperApp extends ConsumerWidget {
  const MusicHelperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);

    return MaterialApp(
      title: '音乐助手',
      debugShowCheckedModeBanner: false,
      theme: DarkTheme.themeData,
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
