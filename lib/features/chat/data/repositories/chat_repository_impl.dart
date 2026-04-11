import 'dart:async';
import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_cliente/features/chat/domain/repositories/chat_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  @override
  Stream<List<ChatMessage>> getMessages(String professionalId) {
    if (!_controllers.containsKey(professionalId)) {
      _controllers[professionalId] = StreamController<List<ChatMessage>>.broadcast();
      _messages[professionalId] = [
        ChatMessage(
          id: '1',
          senderId: professionalId,
          receiverId: 'me',
          text: '¡Hola! He recibido tu solicitud. ¿En qué puedo ayudarte hoy?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isMe: false,
        ),
      ];
      _controllers[professionalId]!.add(_messages[professionalId]!);
    }
    return _controllers[professionalId]!.stream;
  }

  @override
  Future<void> sendMessage(String professionalId, String text) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      receiverId: professionalId,
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    if (!_messages.containsKey(professionalId)) {
      _messages[professionalId] = [];
    }
    _messages[professionalId]!.add(message);
    _controllers[professionalId]?.add(List.from(_messages[professionalId]!));

    // Simulate professional response
    Future.delayed(const Duration(seconds: 2), () {
      final response = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: professionalId,
        receiverId: 'me',
        text: 'Excelente, estaré pendiente. Dame un momento para revisar los detalles.',
        timestamp: DateTime.now(),
        isMe: false,
      );
      _messages[professionalId]!.add(response);
      _controllers[professionalId]?.add(List.from(_messages[professionalId]!));
    });
  }
}
