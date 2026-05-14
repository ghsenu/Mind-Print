import 'package:flutter/material.dart';
import 'package:mind_print/app/router.dart';
import 'package:mind_print/app/theme.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';
import 'package:mind_print/features/shared/widgets/connectivity_wrapper.dart';

class MindPrintApp extends StatelessWidget {
  const MindPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mind Print',
      theme: buildMindPrintTheme(),
      initialRoute: AppRoutes.splash,
      routes: appRoutes,
      builder: (context, child) {
        return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
