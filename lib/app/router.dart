import 'package:flutter/material.dart';
import 'package:mind_print/features/analytics/screens/analytics_tab.dart';
import 'package:mind_print/features/auth/screens/login_screen.dart';
import 'package:mind_print/features/auth/screens/onboarding_questionnaire_screen.dart';
import 'package:mind_print/features/auth/screens/signup_screen.dart';
import 'package:mind_print/features/auth/screens/splash_screen.dart';
import 'package:mind_print/features/coping/screens/toolkit_screen.dart';
import 'package:mind_print/features/home/screens/home_screen.dart';
import 'package:mind_print/features/journal/screens/journal_tab.dart';
import 'package:mind_print/features/reports/screens/export_screen.dart';
import 'package:mind_print/features/settings/screens/settings_screen.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

final Map<String, WidgetBuilder> appRoutes = <String, WidgetBuilder>{
  AppRoutes.splash: (_) => const SplashScreen(),
  AppRoutes.login: (_) => const LoginScreen(),
  AppRoutes.signup: (_) => const SignUpScreen(),
  AppRoutes.onboardingQuestionnaire:
      (_) => const OnboardingQuestionnaireScreen(),
  AppRoutes.home: (_) => const HomeScreen(),
  AppRoutes.journal: (_) => const JournalTab(),
  AppRoutes.analytics: (_) => const AnalyticsTab(),
  AppRoutes.coping: (_) => const ToolkitScreen(),
  AppRoutes.reports: (_) => const ExportScreen(),
  AppRoutes.settings: (_) => const SettingsScreen(),
};
