import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mind_print/app/app.dart';

void main() {
  testWidgets('Shows splash branding on launch', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MindPrintApp());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText() == 'Mind Print',
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 8));

    // Pump a few more times to allow navigation and animation to complete without waiting indefinitely
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Skip'), findsOneWidget);
  });
}
