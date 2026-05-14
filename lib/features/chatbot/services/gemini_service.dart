import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'You are MindPrint\'s compassionate mental wellness companion for '
          'Sri Lankan university students. Listen actively, reflect the user\'s '
          'emotions with empathy, and suggest evidence-based coping strategies '
          'such as journaling, breathing exercises, grounding, or meditation. '
          'Never provide a medical diagnosis or replace professional care. '
          'Keep responses warm, concise (2–4 sentences), and non-judgmental. '
          'If the user expresses thoughts of self-harm or crisis, gently acknowledge '
          'their pain and direct them to Sri Lanka Sumithrayo at 1926.',
        ),
      ) {
    _session = _model.startChat();
  }

  final GenerativeModel _model;
  late ChatSession _session;

  Stream<String> sendMessage(String text) async* {
    final response = _session.sendMessageStream(Content.text(text));
    await for (final chunk in response) {
      final token = chunk.text;
      if (token != null && token.isNotEmpty) yield token;
    }
  }

  void clearHistory() {
    _session = _model.startChat();
  }
}
