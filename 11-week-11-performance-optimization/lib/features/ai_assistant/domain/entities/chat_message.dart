enum MessageSender { user, ai, system }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isStreaming = false,
    this.isError = false,
    this.isOfflineFallback = false,
  });

  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isStreaming;
  final bool isError;
  final bool isOfflineFallback;

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isStreaming,
    bool? isError,
    bool? isOfflineFallback,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      isError: isError ?? this.isError,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
    );
  }
}
