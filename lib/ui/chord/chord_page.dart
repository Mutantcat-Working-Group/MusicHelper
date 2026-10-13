import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_helper/l10n/app_localizations.dart';
import '../../providers/audio_provider.dart';
import '../../ffi/dsp_bridge.dart';
import '../../domain/chord.dart';
import 'dart:math' as math;

class ChordPage extends ConsumerWidget {
  const ChordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
          Icon(
            Icons.piano,
            size: 64,
            color: const Color(0xFF8892B0),
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

    final chordResult = ChordResult(
      rootIndex: result.rootIndex,
      quality: quality,
      bassIndex: result.bassIndex,
      confidence: result.confidence,
      detectedNotes: {},
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
