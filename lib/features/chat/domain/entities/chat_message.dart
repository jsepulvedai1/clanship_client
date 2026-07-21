enum ChatMessageType { text, appointment, image, audio }

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final ChatMessageType type;
  final String? fileUrl;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.type = ChatMessageType.text,
    this.fileUrl,
  });
}
