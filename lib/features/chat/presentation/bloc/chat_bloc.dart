import 'dart:async';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_cliente/features/chat/domain/repositories/chat_repository.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:flutter/foundation.dart';
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
  final String? fileBase64;
  final String? fileName;
  final String? messageType;

  SendMessage(
    this.professionalId, 
    this.text, {
    this.fileBase64,
    this.fileName,
    this.messageType,
  });
}

class UpdateMessages extends ChatEvent {
  final List<ChatMessage> messages;
  UpdateMessages(this.messages);
}

class TriggerJobCancelled extends ChatEvent {}
class AcceptJobProposal extends ChatEvent {}
class RejectJobProposal extends ChatEvent {}

// States
abstract class ChatState {}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String? jobStatus;
  ChatLoaded(this.messages, {this.jobStatus});
}
class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
class JobCancelledState extends ChatState {
  final bool byMe;
  JobCancelledState({required this.byMe});
}

// Bloc
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _subscription;
  Timer? _jobStatusTimer;

  String? _currentRoomId;
  String? _currentJobId;
  String? _currentJobStatus;

  ChatBloc(this._repository) : super(ChatInitial()) {
    on<LoadMessages>((event, emit) async {
      emit(ChatLoading());
      await _subscription?.cancel();
      _jobStatusTimer?.cancel();

      try {
        final professionalIdInt = int.parse(event.professionalId);
        final jobIdInt = event.jobId != null ? int.tryParse(event.jobId!) : null;
        _currentJobId = event.jobId;

        if (jobIdInt != null) {
          try {
            final jobRepository = getIt<JobRepository>();
            _currentJobStatus = await jobRepository.getJobStatus(jobIdInt);
            if (_currentJobStatus == 'CANCELLED') {
              emit(JobCancelledState(byMe: false));
              return;
            }
          } catch (_) {}
        }

        _currentRoomId = await _repository.getOrCreateChatRoom(professionalIdInt, jobId: jobIdInt);
        
        _subscription = _repository.getMessages(_currentRoomId!).listen(
          (messages) => add(UpdateMessages(messages)),
        );

        if (jobIdInt != null) {
          _jobStatusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
            try {
              final jobRepository = getIt<JobRepository>();
              final status = await jobRepository.getJobStatus(jobIdInt);
              if (status == 'CANCELLED') {
                timer.cancel();
                add(TriggerJobCancelled());
              } else if (status != _currentJobStatus) {
                _currentJobStatus = status;
                if (state is ChatLoaded) {
                  final currentState = state as ChatLoaded;
                  emit(ChatLoaded(currentState.messages, jobStatus: status));
                }
              }
            } catch (_) {}
          });
        }
      } catch (e) {
        emit(ChatError('Lo sentimos, hubo un error en el chat.'));
      }
    });

    on<UpdateMessages>((event, emit) {
      // Si llega un mensaje de propuesta y aún no tenemos status SCHEDULED
      // lo actualizamos de inmediato sin esperar el timer de polling.
      final hasProposal = event.messages.any(
        (m) => !m.isMe && m.text.startsWith('Propuesta de visita:'),
      );
      final pendingStatuses = {null, 'REQUESTED'};
      if (hasProposal && pendingStatuses.contains(_currentJobStatus)) {
        _currentJobStatus = 'SCHEDULED';
      }
      emit(ChatLoaded(event.messages, jobStatus: _currentJobStatus));
    });

    on<TriggerJobCancelled>((event, emit) {
      _jobStatusTimer?.cancel();
      _subscription?.cancel();
      emit(JobCancelledState(byMe: false));
    });

    on<AcceptJobProposal>((event, emit) async {
      if (_currentJobId != null && _currentRoomId != null) {
        try {
          final jobRepository = getIt<JobRepository>();
          final jobIdInt = int.parse(_currentJobId!);
          await jobRepository.updateJobStatus(jobIdInt, 'AGREED');
          _currentJobStatus = 'AGREED';
          if (state is ChatLoaded) {
            final currentState = state as ChatLoaded;
            emit(ChatLoaded(currentState.messages, jobStatus: 'AGREED'));
          }
          await _repository.sendMessage(_currentRoomId!, 'Propuesta de visita aceptada por el cliente.');
        } catch (_) {}
      }
    });

    on<RejectJobProposal>((event, emit) async {
      _jobStatusTimer?.cancel();
      if (_currentJobId != null) {
        try {
          final jobRepository = getIt<JobRepository>();
          final jobIdInt = int.parse(_currentJobId!);
          await jobRepository.updateJobStatus(jobIdInt, 'CANCELLED');
          _subscription?.cancel();
          emit(JobCancelledState(byMe: true));
        } catch (_) {}
      }
    });

    on<SendMessage>((event, emit) async {
      if (_currentRoomId != null) {
        try {
          await _repository.sendMessage(
            _currentRoomId!, 
            event.text,
            fileBase64: event.fileBase64,
            fileName: event.fileName,
            messageType: event.messageType,
          );
        } catch (e) {
          debugPrint('Error sending message: $e');
        }
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _jobStatusTimer?.cancel();
    return super.close();
  }
}
