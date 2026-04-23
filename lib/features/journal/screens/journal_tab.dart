import 'package:flutter/material.dart';
import 'package:mind_print/features/journal/screens/voice_journal_screen.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';

class JournalTab extends StatelessWidget {
  const JournalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD7E2EE)),
              ),
              child: const Text(
                'Start a new journal entry to analyze your emotions.',
                style: TextStyle(fontSize: 15, color: Color(0xFF334155)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoiceJournalScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Write Journal'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.emotionResult);
                },
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('View Last Analysis Result'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
