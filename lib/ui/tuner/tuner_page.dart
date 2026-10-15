import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_helper/l10n/app_localizations.dart';
import '../../providers/audio_provider.dart';
import '../../providers/settings_provider.dart';
import '../../domain/tuning.dart';
import '../../domain/note.dart';

/// 调音器主页面
class TunerPage extends ConsumerWidget {
  const TunerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tunerState = ref.watch(tunerProvider);
    final tolerance = ref.watch(toleranceProvider);
    final selectedTuningId = ref.watch(selectedTuningIdProvider);

    final allTunings = [
      ...Tuning.allPresets(),
      ...ref.watch(customTuningsProvider),
    ];
    final selectedTuning = allTunings.firstWhere(
      (t) => t.id == selectedTuningId,
      orElse: () => Tuning.standardGuitar(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tab_tuner),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 调弦选择
            _buildTuningSelector(context, ref, l10n, selectedTuning),
            const SizedBox(height: 16),
            // 表盘
            Expanded(
              child: Center(
                child: TunerDial(
                  frequency: tunerState.frequency,
                  note: tunerState.note,
                  centsDeviation: tunerState.centsDeviation,
                  tolerance: tolerance,
                  isActive: tunerState.isActive,
                ),
              ),
            ),
            // 当前弦指示
            _buildStringIndicator(context, l10n, selectedTuning, tunerState),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTuningSelector(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Tuning selectedTuning,
  ) {
    final allTunings = [
      ...Tuning.allPresets(),
      ...ref.watch(customTuningsProvider),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2A45)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTuning.id,
          isExpanded: true,
          dropdownColor: const Color(0xFF141B2D),
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(color: Color(0xFFE8EAFF), fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00D4FF)),
          items: allTunings.map((t) {
            return DropdownMenuItem(
              value: t.id,
              child: Text(_getTuningName(context, t.nameKey)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedTuningIdProvider.notifier).setTuning(value);
            }
          },
        ),
      ),
    );
  }

  String _getTuningName(BuildContext context, String nameKey) {
    // 临时映射，后续用 i18n
    final map = {
      'tuning_standard_guitar': '标准吉他 EADGBE',
      'tuning_half_step_down': '降半音 EbAbDbGbBbEb',
      'tuning_open_d': 'Open D 调弦',
      'tuning_open_g': 'Open G 调弦',
      'tuning_standard_bass': '标准贝斯 EADG',
      'tuning_five_string_bass': '5弦贝斯 BEADG',
      'tuning_standard_ukulele': '尤克里里 GCEA',
      'tuning_standard_violin': '小提琴 GDAE',
      'tuning_standard_cello': '大提琴 CGDA',
    };
    return map[nameKey] ?? nameKey;
  }

  Widget _buildStringIndicator(
    BuildContext context,
    AppLocalizations l10n,
    Tuning tuning,
    TunerState state,
  ) {
    if (!state.isActive || state.note == null) {
      return const SizedBox.shrink();
    }

    // 找到最接近的弦
    int closestString = -1;
    double minCents = double.infinity;
    for (int i = 0; i < tuning.strings.length; i++) {
      final stringNote = tuning.strings[i];
      final cents = (state.note!.midiNumber - stringNote.midiNumber) * 100.0;
      if (cents.abs() < minCents) {
        minCents = cents.abs();
        closestString = i;
      }
    }

    if (closestString < 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2A45)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tune, color: Color(0xFF00D4FF), size: 20),
          const SizedBox(width: 8),
          Text(
            '${l10n.string_label} ${closestString + 1} — ${tuning.strings[closestString].displayName}',
            style: const TextStyle(
              color: Color(0xFFE8EAFF),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// 调音表盘
class TunerDial extends StatelessWidget {
  final double frequency;
  final MusicalNote? note;
  final double centsDeviation;
  final double tolerance;
  final bool isActive;

  const TunerDial({
    super.key,
    required this.frequency,
    this.note,
    required this.centsDeviation,
    required this.tolerance,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isOnPitch = centsDeviation.abs() <= tolerance;
    final isTooHigh = centsDeviation > tolerance;
    final color = !isActive
        ? const Color(0xFF8892B0)
        : isOnPitch
            ? const Color(0xFF00E676)
            : isTooHigh
                ? const Color(0xFFFFAB00)
                : const Color(0xFFFF5252);

    return SizedBox(
      width: 320,
      height: 320,
      child: CustomPaint(
        painter: _DialPainter(
          centsDeviation: centsDeviation,
          tolerance: tolerance,
          color: color,
          isActive: isActive,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note != null) ...[
                Text(
                  note!.name.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 96,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -2,
                  ),
                ),
                Text(
                  '${note!.octave}',
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${frequency.toStringAsFixed(1)} Hz',
                  style: const TextStyle(
                    color: Color(0xFF8892B0),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${centsDeviation >= 0 ? '+' : ''}${centsDeviation.toStringAsFixed(1)} ¢',
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  '—',
                  style: TextStyle(
                    color: const Color(0xFF8892B0),
                    fontSize: 96,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '等待音频输入...',
                  style: TextStyle(
                    color: Color(0xFF8892B0),
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double centsDeviation;
  final double tolerance;
  final Color color;
  final bool isActive;

  _DialPainter({
    required this.centsDeviation,
    required this.tolerance,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 背景弧
    final bgArc = Paint()
      ..color = const Color(0xFF1E2A45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgArc,
    );

    // 容差区域
    final toleranceArc = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final toleranceAngle = (tolerance / 50.0) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi - toleranceAngle,
      toleranceAngle * 2,
      false,
      toleranceArc,
    );

    if (isActive) {
      // 偏差指针
      final clampedCents = centsDeviation.clamp(-50.0, 50.0);
      final angle = math.pi * 0.75 + (clampedCents / 50.0) * math.pi * 1.5;

      final needlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final needleEnd = Offset(
        center.dx + math.cos(angle) * (radius - 10),
        center.dy + math.sin(angle) * (radius - 10),
      );

      canvas.drawLine(center, needleEnd, needlePaint);

      // 中心圆点
      canvas.drawCircle(
        center,
        8,
        Paint()..color = color,
      );
    }

    // 刻度标记
    final tickPaint = Paint()
      ..color = const Color(0xFF8892B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = -5; i <= 5; i++) {
      if (i == 0) continue;
      final tickAngle = math.pi * 0.75 + (i / 5.0) * math.pi * 1.5;
      final inner = Offset(
        center.dx + math.cos(tickAngle) * (radius - 16),
        center.dy + math.sin(tickAngle) * (radius - 16),
      );
      final outer = Offset(
        center.dx + math.cos(tickAngle) * (radius - 24),
        center.dy + math.sin(tickAngle) * (radius - 24),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.centsDeviation != centsDeviation ||
        oldDelegate.isActive != isActive ||
        oldDelegate.color != color;
  }
}
