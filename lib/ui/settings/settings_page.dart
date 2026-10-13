import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_helper/l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../domain/tuning.dart';
import '../../domain/note.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tolerance = ref.watch(toleranceProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tab_settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 容差设置
          _buildToleranceCard(context, l10n, ref, tolerance),
          const SizedBox(height: 16),
          // 语言设置
          _buildLanguageCard(context, l10n, ref, language),
          const SizedBox(height: 16),
          // 自定义调弦
          _buildCustomTuningCard(context, l10n, ref),
          const SizedBox(height: 16),
          // 关于
          _buildAboutCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildToleranceCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    double tolerance,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tolerance_label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE8EAFF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tolerance_desc,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8892B0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: tolerance,
                    min: 2,
                    max: 20,
                    divisions: 18,
                    label: '±${tolerance.round()} ¢',
                    onChanged: (value) {
                      ref.read(toleranceProvider.notifier).setTolerance(value);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2A45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '±${tolerance.round()} ¢',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00D4FF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    String language,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language_label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE8EAFF),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'zh', label: Text('简体中文')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {language},
              onSelectionChanged: (Set<String> selected) {
                ref.read(languageProvider.notifier).setLanguage(selected.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF00D4FF);
                  }
                  return const Color(0xFF1E2A45);
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF0A0E1A);
                  }
                  return const Color(0xFFE8EAFF);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTuningCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final customTunings = ref.watch(customTuningsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.custom_tuning_label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE8EAFF),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF00D4FF)),
                  onPressed: () => _showAddTuningDialog(context, l10n, ref),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (customTunings.isEmpty)
              Text(
                l10n.no_custom_tunings,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8892B0),
                ),
              )
            else
              ...customTunings.map((tuning) => ListTile(
                    title: Text(
                      _getCustomTuningName(tuning),
                      style: const TextStyle(color: Color(0xFFE8EAFF)),
                    ),
                    subtitle: Text(
                      tuning.strings.map((n) => n.displayName).join(' · '),
                      style: const TextStyle(
                        color: Color(0xFF8892B0),
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFFF5252)),
                      onPressed: () {
                        ref
                            .read(customTuningsProvider.notifier)
                            .removeTuning(tuning.id);
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  String _getCustomTuningName(Tuning tuning) {
    return tuning.strings.map((n) => n.name.label).join(' / ');
  }

  void _showAddTuningDialog(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final nameController = TextEditingController();
    int stringCount = 6;
    final List<NoteName> selectedNotes = List.filled(6, NoteName.c);
    final List<int> selectedOctaves = List.filled(6, 4);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF141B2D),
          title: Text(
            l10n.add_custom_tuning,
            style: const TextStyle(color: Color(0xFFE8EAFF)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.tuning_name,
                    labelStyle: const TextStyle(color: Color(0xFF8892B0)),
                  ),
                  style: const TextStyle(color: Color(0xFFE8EAFF)),
                ),
                const SizedBox(height: 16),
                Text(
                  '${l10n.string_count}: $stringCount',
                  style: const TextStyle(color: Color(0xFF8892B0)),
                ),
                Slider(
                  value: stringCount.toDouble(),
                  min: 2,
                  max: 8,
                  divisions: 6,
                  label: '$stringCount',
                  onChanged: (v) {
                    setState(() {
                      stringCount = v.round();
                      while (selectedNotes.length < stringCount) {
                        selectedNotes.add(NoteName.c);
                        selectedOctaves.add(4);
                      }
                      while (selectedNotes.length > stringCount) {
                        selectedNotes.removeLast();
                        selectedOctaves.removeLast();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                ...List.generate(stringCount, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '${i + 1}. ',
                          style: const TextStyle(color: Color(0xFF8892B0)),
                        ),
                        Expanded(
                          child: DropdownButton<NoteName>(
                            value: selectedNotes[i],
                            dropdownColor: const Color(0xFF141B2D),
                            isExpanded: true,
                            style: const TextStyle(color: Color(0xFFE8EAFF)),
                            items: NoteName.values.map((n) {
                              return DropdownMenuItem(
                                value: n,
                                child: Text(n.label),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => selectedNotes[i] = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedOctaves[i],
                            dropdownColor: const Color(0xFF141B2D),
                            isExpanded: true,
                            style: const TextStyle(color: Color(0xFFE8EAFF)),
                            items: List.generate(8, (i) => i).map((o) {
                              return DropdownMenuItem(
                                value: o,
                                child: Text('Oct $o'),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => selectedOctaves[i] = v);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Color(0xFF8892B0)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final tuning = Tuning(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  nameKey: nameController.text.isNotEmpty
                      ? nameController.text
                      : 'Custom',
                  strings: List.generate(
                    stringCount,
                    (i) => MusicalNote(selectedNotes[i], selectedOctaves[i]),
                  ),
                  isPreset: false,
                );
                ref.read(customTuningsProvider.notifier).addTuning(tuning);
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.about_label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE8EAFF),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'MusicHelper v1.0.0',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8892B0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.about_desc,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8892B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
