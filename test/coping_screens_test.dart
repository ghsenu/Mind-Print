import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/features/coping/screens/breathing_screen.dart';

void main() {
  testWidgets('BreathingScreen UI loads correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: BreathingScreen())),
    );

    expect(find.text('Breathing'), findsOneWidget);
    expect(find.text('Choose an exercise to begin'), findsOneWidget);
    expect(find.text('Box Breathing'), findsOneWidget);
  });
}
