import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';

class ChatRoomInfo {
  final String roomId;
  final String? jobId;
  final String? jobStatus;
  final bool hasBeenReviewed;

  ChatRoomInfo({
    required this.roomId,
    this.jobId,
    this.jobStatus,
    this.hasBeenReviewed = false,
  });
}

abstract class ChatRepository {
  Future<ChatRoomInfo> getOrCreateChatRoom(int professionalId, {int? jobId});
  Stream<List<ChatMessage>> getMessages(String roomId);
  Stream<Map<String, dynamic>> getJobStatusEvents(String roomId);
  Future<void> sendMessage(
    String roomId, 
    String text, {
    String? fileBase64, 
    String? fileName, 
    String? messageType,
  });
}
