import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bus/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VahanMitraApp()));
    await tester.pumpAndSettle();
    // Simply ensuring it boots up without exceptions
    expect(true, isTrue);
  });
}
