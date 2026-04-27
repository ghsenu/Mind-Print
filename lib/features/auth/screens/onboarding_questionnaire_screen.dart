import 'package:flutter/material.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class OnboardingQuestionnaireScreen extends StatelessWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Onboarding questionnaire placeholder'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
              child: const Text('Finish & Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
