enum ChatSender {
  user,
  bot,
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  final String id;
  final ChatSender sender;
  final String message;
  final DateTime timestamp;
}
