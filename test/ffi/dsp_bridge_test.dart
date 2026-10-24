import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_helper/ffi/dsp_bridge.dart';

void main() {
  group('DspBridge', () {
    final samples = Float32List.fromList(
      List.generate(512, (i) => (i % 64) / 64.0 - 0.5),
    );

    test('构造不抛异常(库可用与否都安全)', () {
      expect(() => DspBridge(), returnsNormally);
    });

    test('所有检测方法不抛异常', () {
      final bridge = DspBridge();
      expect(() => bridge.detectPitch(samples, 44100), returnsNormally);
      expect(() => bridge.detectChord(samples, 44100), returnsNormally);
      expect(() => bridge.detectMultiplePitches(samples, 44100), returnsNormally);
    });

    test('空输入返回中性结果', () {
      final bridge = DspBridge();
      expect(bridge.detectPitch(Float32List(0), 44100), 0);
      expect(bridge.detectChord(Float32List(0), 44100).confidence, 0);
      expect(bridge.detectMultiplePitches(Float32List(0), 44100).count, 0);
    });

    test('库不可用时返回空结果而不崩溃', () {
      final bridge = DspBridge();
      if (bridge.isAvailable) return; // 真机上库可用,跳过降级断言
      expect(bridge.detectPitch(samples, 44100), 0);
      expect(bridge.detectChord(samples, 44100).confidence, 0);
      expect(bridge.detectChord(samples, 44100).chroma.length, 12);
      expect(bridge.detectMultiplePitches(samples, 44100).count, 0);
    });
  });

  group('ChordResultData', () {
    test('empty() 返回 12 维零向量', () {
      final empty = ChordResultData.empty();
      expect(empty.rootIndex, 0);
      expect(empty.qualityIndex, 0);
      expect(empty.bassIndex, 0);
      expect(empty.confidence, 0);
      expect(empty.chroma.length, 12);
      expect(empty.detectedNotes.length, 12);
      expect(empty.chroma.every((v) => v == 0), isTrue);
    });
  });

  group('MultiPitchResultData', () {
    test('empty() 返回空列表', () {
      final empty = MultiPitchResultData.empty();
      expect(empty.count, 0);
      expect(empty.frequencies, isEmpty);
      expect(empty.intensities, isEmpty);
    });
  });
}
