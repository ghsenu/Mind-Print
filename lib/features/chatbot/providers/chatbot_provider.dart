import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/core/config/env.dart';
import 'package:mind_print/features/chatbot/models/chat_message.dart';
import 'package:mind_print/features/chatbot/services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>(
  (ref) => GeminiService(Env.geminiApiKey),
);

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(ref.watch(geminiServiceProvider)),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier(this._gemini) : super([]) {
    _addWelcome();
  }

  final GeminiService _gemini;
  bool _isBusy = false;

  void _addWelcome() {
    state = [
      ChatMessage.botMessage(
        text:
            'Hi there! 👋 I\'m your MindPrint wellness companion. '
            'How are you feeling today?',
        isStreaming: false,
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isBusy) return;

    _isBusy = true;

    // Append user message
    state = [...state, ChatMessage.userMessage(trimmed)];

    // Append a streaming bot placeholder
    final botMsg = ChatMessage.botMessage();
    state = [...state, botMsg];

    try {
      final stream = _gemini.sendMessage(trimmed);
      await for (final token in stream) {
        // Find the bot placeholder and append the token
        state = [
          for (final m in state)
            if (m.id == botMsg.id)
              m.copyWith(text: m.text + token)
            else
              m,
        ];
      }
    } catch (_) {
      state = [
        for (final m in state)
          if (m.id == botMsg.id)
            m.copyWith(
              text: 'Sorry, I ran into a problem. Please try again.',
              isStreaming: false,
            )
          else
            m,
      ];
    } finally {
      // Mark streaming done
      state = [
        for (final m in state)
          if (m.id == botMsg.id) m.copyWith(isStreaming: false) else m,
      ];
      _isBusy = false;
    }
  }

  void clearHistory() {
    _gemini.clearHistory();
    _addWelcome();
  }
}
