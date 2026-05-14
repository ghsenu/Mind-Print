enum MessageSender { user, bot }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime createdAt;
  final bool isStreaming;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
    this.isStreaming = false,
  });

  ChatMessage copyWith({String? text, bool? isStreaming}) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      sender: sender,
      createdAt: createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  static String _newId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${Object().hashCode}';

  static ChatMessage userMessage(String text) => ChatMessage(
    id: _newId(),
    text: text,
    sender: MessageSender.user,
    createdAt: DateTime.now(),
  );

  static ChatMessage botMessage({String text = '', bool isStreaming = true}) =>
      ChatMessage(
        id: _newId(),
        text: text,
        sender: MessageSender.bot,
        createdAt: DateTime.now(),
        isStreaming: isStreaming,
      );
}
