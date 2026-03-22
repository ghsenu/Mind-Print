import 'package:flutter/material.dart';
import 'package:mind_print/features/analytics/screens/analytics_tab.dart';
import 'package:mind_print/features/auth/screens/biometrics_privacy_screen.dart';
import 'package:mind_print/features/auth/screens/congratulations_screen.dart';
import 'package:mind_print/features/auth/screens/forgot_password_screen.dart';
import 'package:mind_print/features/auth/screens/login_screen.dart';
import 'package:mind_print/features/auth/screens/onboarding_questionnaire_screen.dart';
import 'package:mind_print/features/auth/screens/onboarding_screen.dart';
import 'package:mind_print/features/auth/screens/otp.dart';
import 'package:mind_print/features/auth/screens/reset_password_screen.dart';
import 'package:mind_print/features/auth/screens/signup_screen.dart';
import 'package:mind_print/features/auth/screens/splash_screen.dart';
import 'package:mind_print/features/coping/screens/toolkit_screen.dart';
import 'package:mind_print/features/home/screens/home_screen.dart';
import 'package:mind_print/features/journal/screens/journal_tab.dart';
import 'package:mind_print/features/notifications/screens/notification_screen.dart';
import 'package:mind_print/features/reports/screens/export_screen.dart';
import 'package:mind_print/features/settings/screens/settings_screen.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

final Map<String, WidgetBuilder> appRoutes = <String, WidgetBuilder>{
  AppRoutes.splash: (_) => const SplashScreen(),
  AppRoutes.onboarding: (_) => const OnboardingScreen(),
  AppRoutes.login: (_) => const LoginScreen(),
  AppRoutes.signup: (_) => const SignUpScreen(),
  AppRoutes.congratulations: (_) => const CongratulationsScreen(),
  AppRoutes.biometricsPrivacy: (_) => const BiometricsPrivacyScreen(),
  AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
  AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),
  AppRoutes.otp: (_) => const OtpScreen(),
  AppRoutes.onboardingQuestionnaire:
      (_) => const OnboardingQuestionnaireScreen(),
  AppRoutes.home: (_) => const HomeScreen(),
  AppRoutes.notifications: (_) => const NotificationScreen(),
  AppRoutes.journal: (_) => const JournalTab(),
  AppRoutes.analytics: (_) => const AnalyticsTab(),
  AppRoutes.coping: (_) => const ToolkitScreen(),
  AppRoutes.reports: (_) => const ExportScreen(),
  AppRoutes.settings: (_) => const SettingsScreen(),
};
