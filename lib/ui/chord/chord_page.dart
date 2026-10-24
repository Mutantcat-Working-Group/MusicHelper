import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_helper/l10n/app_localizations.dart';
import '../../providers/audio_provider.dart';
import '../../ffi/dsp_bridge.dart' hide ChordResult;
import '../../domain/chord.dart';

class ChordPage extends ConsumerWidget {
  const ChordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final chordState = ref.watch(chordProvider);
    final result = chordState.result;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tab_chord),
      ),
      body: SafeArea(
        child: result == null
            ? _buildWaiting(context, l10n)
            : _buildResult(context, l10n, result),
      ),
    );
  }

  Widget _buildWaiting(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.piano,
            size: 64,
            color: Color(0xFF8892B0),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.chord_waiting,
            style: const TextStyle(
              color: Color(0xFF8892B0),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, AppLocalizations l10n, ChordResultData result) {
    final qualities = ChordQuality.values;
    final quality = result.qualityIndex < qualities.length
        ? qualities[result.qualityIndex]
        : ChordQuality.major;

    // 把 FFI 传来的 detectedNotes(每个音级的强度)转成 domain 模型要的 Map
    final detectedNotes = <int, double>{};
    for (int i = 0; i < result.detectedNotes.length && i < 12; i++) {
      final intensity = result.detectedNotes[i];
      if (intensity > 0.05) detectedNotes[i] = intensity;
    }

    final chordResult = ChordResult(
      rootIndex: result.rootIndex,
      quality: quality,
      bassIndex: result.bassIndex,
      confidence: result.confidence,
      detectedNotes: detectedNotes,
      chroma: result.chroma,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 和弦名
          _buildChordName(context, l10n, chordResult),
          const SizedBox(height: 16),
          // 置信度
          _buildConfidence(context, l10n, chordResult),
          const SizedBox(height: 16),
          // 构成音
          _buildNotes(context, l10n, chordResult),
          const SizedBox(height: 16),
          // Chroma 可视化
          _buildChroma(context, l10n, chordResult),
        ],
      ),
    );
  }

  Widget _buildChordName(BuildContext context, AppLocalizations l10n, ChordResult chord) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              chord.baseName,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w300,
                color: Color(0xFF00D4FF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getChordQualityName(l10n, chord.quality),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF8892B0),
              ),
            ),
            if (chord.isInversion) ...[
              const SizedBox(height: 8),
              Text(
                chord.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C4DFF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.inversion_label} ${chord.inversionNumber + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8892B0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 和弦类型显示名:从 l10n 读取(chord_* 系列 key)
  String _getChordQualityName(AppLocalizations l10n, ChordQuality quality) {
    switch (quality.nameKey) {
      case 'chord_major':
        return l10n.chord_major;
      case 'chord_minor':
        return l10n.chord_minor;
      case 'chord_augmented':
        return l10n.chord_augmented;
      case 'chord_diminished':
        return l10n.chord_diminished;
      case 'chord_dominant7':
        return l10n.chord_dominant7;
      case 'chord_major7':
        return l10n.chord_major7;
      case 'chord_minor7':
        return l10n.chord_minor7;
      case 'chord_minor7b5':
        return l10n.chord_minor7b5;
      case 'chord_diminished7':
        return l10n.chord_diminished7;
      case 'chord_sus2':
        return l10n.chord_sus2;
      case 'chord_sus4':
        return l10n.chord_sus4;
      case 'chord_major6':
        return l10n.chord_major6;
      case 'chord_minor6':
        return l10n.chord_minor6;
      case 'chord_dominant9':
        return l10n.chord_dominant9;
      case 'chord_major9':
        return l10n.chord_major9;
      case 'chord_minor9':
        return l10n.chord_minor9;
      case 'chord_add9':
        return l10n.chord_add9;
      case 'chord_minorAdd9':
        return l10n.chord_minorAdd9;
      default:
        return quality.symbol;
    }
  }

  Widget _buildConfidence(BuildContext context, AppLocalizations l10n, ChordResult chord) {
    final pct = (chord.confidence * 100).clamp(0, 100);
    final color = pct > 70
        ? const Color(0xFF00E676)
        : pct > 40
            ? const Color(0xFFFFAB00)
            : const Color(0xFFFF5252);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.confidence_label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8892B0),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: const Color(0xFF1E2A45),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              '${pct.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes(BuildContext context, AppLocalizations l10n, ChordResult chord) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final chordTones = chord.chordToneIndices;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notes_label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8892B0),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chordTones.map((idx) {
                final isRoot = idx == chord.rootIndex;
                final isBass = idx == chord.bassIndex;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isRoot
                        ? const Color(0xFF00D4FF).withValues(alpha: 0.2)
                        : isBass
                            ? const Color(0xFF7C4DFF).withValues(alpha: 0.2)
                            : const Color(0xFF1E2A45),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isRoot
                          ? const Color(0xFF00D4FF)
                          : isBass
                              ? const Color(0xFF7C4DFF)
                              : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    noteNames[idx],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isRoot || isBass
                          ? Colors.white
                          : const Color(0xFFE8EAFF),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.bass_note}: ${noteNames[chord.bassIndex]}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8892B0),
              ),
            ),
            // 实际检测到的音(来自 DSP 的 chroma 强度),与理论构成音对照
            if (chord.detectedNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.detected_notes_label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8892B0),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chord.detectedNotes.entries.map((e) {
                  final isChordTone = chord.chordToneIndices.contains(e.key);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isChordTone
                          ? const Color(0xFF00E676).withValues(alpha: 0.12)
                          : const Color(0xFF1E2A45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${noteNames[e.key]} ${(e.value * 100).round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: isChordTone
                            ? const Color(0xFF00E676)
                            : const Color(0xFF8892B0),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChroma(BuildContext context, AppLocalizations l10n, ChordResult chord) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final maxVal = chord.chroma.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chroma_label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8892B0),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (i) {
                  final val = maxVal > 0 ? chord.chroma[i] / maxVal : 0.0;
                  final isChordTone = chord.chordToneIndices.contains(i);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            noteNames[i],
                            style: TextStyle(
                              fontSize: 10,
                              color: isChordTone
                                  ? const Color(0xFF00D4FF)
                                  : const Color(0xFF8892B0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 80 * val.clamp(0.0, 1.0),
                            decoration: BoxDecoration(
                              color: isChordTone
                                  ? const Color(0xFF00D4FF)
                                  : const Color(0xFF1E2A45),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
