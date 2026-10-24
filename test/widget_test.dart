import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_helper/app.dart';

void main() {
  testWidgets('应用启动后显示调音器页', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MusicHelperApp()));
    await tester.pumpAndSettle();

    // AppBar 标题与底部导航都显示"调音器"
    expect(find.text('调音器'), findsWidgets);
    // 测试环境没有音频输入,表盘显示等待提示
    expect(find.text('等待音频输入...'), findsOneWidget);

    // 卸载以触发 ProviderScope 的 dispose(关闭后台 isolate)
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('可以切换到和弦识别页', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MusicHelperApp()));
    await tester.pumpAndSettle();

    // 切换前只有底部导航有该文本
    await tester.tap(find.text('和弦识别'));
    await tester.pumpAndSettle();

    // 切换后 AppBar 与底部导航都有该文本
    expect(find.text('和弦识别'), findsNWidgets(2));
    expect(find.text('等待音频输入...'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('可以切换到设置页并显示容差滑块', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MusicHelperApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsNWidgets(2));
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('±5 ¢'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });
}
