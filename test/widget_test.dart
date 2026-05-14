import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/app/router.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('Shows splash branding on launch', (WidgetTester tester) async {
    // Set a standard mobile screen size
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build the app structure exactly like main.dart
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          initialRoute: AppRoutes.splash,
          routes: appRoutes,
        ),
      ),
    );

    // Advance the clock to ensure animations and timers start correctly
    await tester.pump(const Duration(seconds: 1));
    
    // Final pump to clear the 8-second splash timer
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
  });
}
