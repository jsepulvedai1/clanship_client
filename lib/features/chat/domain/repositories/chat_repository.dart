import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<String> getOrCreateChatRoom(int professionalId, {int? jobId});
  Stream<List<ChatMessage>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, String text);
}
