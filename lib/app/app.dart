import 'package:flutter/material.dart';
import 'package:mind_print/app/router.dart';
import 'package:mind_print/app/theme.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class MindPrintApp extends StatelessWidget {
  const MindPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Print',
      theme: buildMindPrintTheme(),
      initialRoute: AppRoutes.splash,
      routes: appRoutes,
    );
  }
}
