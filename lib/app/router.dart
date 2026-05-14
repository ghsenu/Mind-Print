import 'package:flutter/material.dart';
import 'package:mind_print/features/analytics/screens/analytics_tab.dart';
import 'package:mind_print/features/auth/screens/biometrics_privacy_screen.dart';
import 'package:mind_print/features/auth/screens/congratulations_screen.dart';
import 'package:mind_print/features/auth/screens/forgot_password_screen.dart';
import 'package:mind_print/features/auth/screens/login_screen.dart';
import 'package:mind_print/features/auth/screens/onboarding_questionnaire_screen.dart';
import 'package:mind_print/features/auth/screens/onboarding_screen.dart';
import 'package:mind_print/features/auth/screens/otp.dart';
import 'package:mind_print/features/auth/screens/phone_auth_screen.dart';
import 'package:mind_print/features/auth/screens/reset_password_screen.dart';
import 'package:mind_print/features/auth/screens/signup_screen.dart';
import 'package:mind_print/features/auth/screens/splash_screen.dart';
import 'package:mind_print/features/coping/screens/activities_screen.dart';
import 'package:mind_print/features/coping/screens/breathing_screen.dart';
import 'package:mind_print/features/coping/screens/music_therapy_screen.dart';
import 'package:mind_print/features/coping/screens/meditation_screen.dart';
import 'package:mind_print/features/coping/screens/cbt_screen.dart';
import 'package:mind_print/features/games/screens/games_screen.dart';
import 'package:mind_print/features/games/screens/star_rain_screen.dart';
import 'package:mind_print/features/games/screens/bubble_pop_screen.dart';
import 'package:mind_print/features/games/screens/memory_match_screen.dart';
import 'package:mind_print/features/games/screens/breathing_ball_screen.dart';
import 'package:mind_print/features/games/screens/ripple_pond_screen.dart';
import 'package:mind_print/features/games/screens/zen_canvas_screen.dart';
import 'package:mind_print/features/home/screens/home_screen.dart';
import 'package:mind_print/features/profile/screens/edit_profile_screen.dart';
import 'package:mind_print/features/journal/screens/journal_tab.dart';
import 'package:mind_print/features/notifications/screens/notification_screen.dart';
import 'package:mind_print/features/reports/screens/export_screen.dart';
import 'package:mind_print/features/settings/screens/settings_screen.dart';
import 'package:mind_print/features/settings/screens/privacy_security_screen.dart';
import 'package:mind_print/features/settings/screens/help_center_screen.dart';
import 'package:mind_print/features/settings/screens/about_screen.dart';
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
  AppRoutes.phoneAuth: (_) => const PhoneAuthScreen(),
  AppRoutes.otp: (context) {
    final verificationId =
        ModalRoute.of(context)?.settings.arguments as String?;
    return OtpScreen(verificationId: verificationId ?? '');
  },
  AppRoutes.onboardingQuestionnaire:
      (_) => const OnboardingQuestionnaireScreen(),
  AppRoutes.home: (_) => const HomeScreen(),
  AppRoutes.notifications: (_) => const NotificationScreen(),
  AppRoutes.journal: (_) => const JournalTab(),
  AppRoutes.analytics: (_) => const AnalyticsTab(),
  AppRoutes.coping: (_) => const ActivitiesScreen(),
  AppRoutes.reports: (_) => const ExportScreen(),
  AppRoutes.settings: (_) => const SettingsScreen(),
  AppRoutes.editProfile: (_) => const EditProfileScreen(),
  AppRoutes.games: (_) => const GamesScreen(),
  AppRoutes.starRain: (_) => const StarRainScreen(),
  AppRoutes.bubblePop: (_) => const BubblePopScreen(),
  AppRoutes.memoryMatch: (_) => const MemoryMatchScreen(),
  AppRoutes.breathingBall: (_) => const BreathingBallScreen(),
  AppRoutes.ripplePond: (_) => const RipplePondScreen(),
  AppRoutes.zenCanvas: (_) => const ZenCanvasScreen(),
  AppRoutes.breathing: (_) => const BreathingScreen(),
  AppRoutes.musicTherapy: (_) => const MusicTherapyScreen(),
  AppRoutes.meditation: (_) => const MeditationScreen(),
  AppRoutes.cbtExercises: (_) => const CbtScreen(),
  AppRoutes.privacySecurity: (_) => const PrivacySecurityScreen(),
  AppRoutes.helpCenter: (_) => const HelpCenterScreen(),
  AppRoutes.about: (_) => const AboutScreen(),
};
