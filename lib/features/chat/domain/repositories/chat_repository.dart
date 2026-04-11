import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> getMessages(String professionalId);
  Future<void> sendMessage(String professionalId, String text);
}
