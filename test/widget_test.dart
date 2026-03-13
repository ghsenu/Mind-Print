import 'package:flutter_test/flutter_test.dart';

import 'package:mind_print/app/app.dart';

void main() {
  testWidgets('Shows splash branding on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const MindPrintApp());

    expect(find.text('Mind Print'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
