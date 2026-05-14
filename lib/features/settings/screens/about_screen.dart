import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About MindPrint')),
      body: const Center(
        child: Text('Version 1.0.0\nBuilt for Mental Wellness'),
      ),
    );
  }
}
