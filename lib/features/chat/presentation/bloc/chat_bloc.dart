import 'dart:async';
import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_cliente/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Events
abstract class ChatEvent {}

class LoadMessages extends ChatEvent {
  final String professionalId;
  final String? jobId;
  LoadMessages(this.professionalId, {this.jobId});
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

  String? _currentRoomId;

  ChatBloc(this._repository) : super(ChatInitial()) {
    on<LoadMessages>((event, emit) async {
      emit(ChatLoading());
      await _subscription?.cancel();

      try {
        final professionalIdInt = int.parse(event.professionalId);
        final jobIdInt = event.jobId != null ? int.tryParse(event.jobId!) : null;
        _currentRoomId = await _repository.getOrCreateChatRoom(professionalIdInt, jobId: jobIdInt);
        
        _subscription = _repository.getMessages(_currentRoomId!).listen(
          (messages) => add(UpdateMessages(messages)),
        );
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    on<UpdateMessages>((event, emit) {
      emit(ChatLoaded(event.messages));
    });

    on<SendMessage>((event, emit) async {
      if (_currentRoomId != null) {
        try {
          await _repository.sendMessage(_currentRoomId!, event.text);
        } catch (e) {
          // You could emit an error state here or show a snackbar
        }
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
