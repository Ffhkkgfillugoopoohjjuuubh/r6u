import 'package:flutter_test/flutter_test.dart';
import 'package:ai_tutor/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EchoApp(initialLocaleCode: 'en'));
    expect(find.text('Echo AI'), findsOneWidget);
  });
}