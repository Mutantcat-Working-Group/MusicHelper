import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_helper/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MusicHelperApp()));
    await tester.pumpAndSettle();
    expect(find.text('音乐助手'), findsOneWidget);
  });
}
