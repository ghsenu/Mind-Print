import 'package:flutter/material.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed:
              () => Navigator.pushReplacementNamed(context, AppRoutes.home),
          child: const Text('Continue to Home'),
        ),
      ),
    );
  }
}
