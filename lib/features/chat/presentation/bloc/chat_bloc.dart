import 'dart:async';
import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_cliente/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Events
abstract class ChatEvent {}

class LoadMessages extends ChatEvent {
  final String professionalId;
  LoadMessages(this.professionalId);
}

class SendMessage extends ChatEvent {
  final String professionalId;
  final String text;
  SendMessage(this.professionalId, this.text);
}

class UpdateMessages extends ChatEvent {
  final List<ChatMessage> messages;
  UpdateMessages(this.messages);
}

// States
abstract class ChatState {}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  ChatLoaded(this.messages);
}
class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

// Bloc
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _subscription;

  ChatBloc(this._repository) : super(ChatInitial()) {
    on<LoadMessages>((event, emit) async {
      emit(ChatLoading());
      await _subscription?.cancel();
      _subscription = _repository.getMessages(event.professionalId).listen(
        (messages) => add(UpdateMessages(messages)),
      );
    });

    on<UpdateMessages>((event, emit) {
      emit(ChatLoaded(event.messages));
    });

    on<SendMessage>((event, emit) async {
      await _repository.sendMessage(event.professionalId, event.text);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
