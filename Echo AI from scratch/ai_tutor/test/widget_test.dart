import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App name test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Echo AI'),
          ),
        ),
      ),
    );

    expect(find.text('Echo AI'), findsOneWidget);
  });
}