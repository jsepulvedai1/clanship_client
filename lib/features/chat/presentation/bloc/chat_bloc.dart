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

class RejectJobProposal extends ChatEvent {
  final String? cancellationReason;
  RejectJobProposal({this.cancellationReason});
}

class RenegotiateJobProposal extends ChatEvent {
  final double proposedPrice;
  RenegotiateJobProposal({required this.proposedPrice});
}

// States
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String? jobStatus;
  final bool hasBeenReviewed;
  final bool isSendingAttachment;
  ChatLoaded(
    this.messages, {
    this.jobStatus,
    this.hasBeenReviewed = false,
    this.isSendingAttachment = false,
  });
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class JobCancelledState extends ChatState {
  final bool byMe;
  JobCancelledState({required this.byMe});
}

class JobAcceptedState extends ChatState {}

// Bloc
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _subscription;
  StreamSubscription? _jobStatusSubscription;

  String? _currentRoomId;
  String? _currentJobId;
  String? _currentJobStatus;
  bool _currentHasBeenReviewed = false;
  bool _isSendingAttachment = false;

  ChatBloc(this._repository) : super(ChatInitial()) {
    on<LoadMessages>((event, emit) async {
      emit(ChatLoading());
      await _subscription?.cancel();
      await _jobStatusSubscription?.cancel();

      try {
        final professionalIdInt = int.parse(event.professionalId);
        final jobIdInt = event.jobId != null
            ? int.tryParse(event.jobId!)
            : null;
        _currentJobId = event.jobId;

        final roomInfo = await _repository.getOrCreateChatRoom(
          professionalIdInt,
          jobId: jobIdInt,
        );
        _currentRoomId = roomInfo.roomId;
        if (roomInfo.jobId != null) {
          _currentJobId = roomInfo.jobId;
        }
        if (roomInfo.jobStatus != null) {
          _currentJobStatus = roomInfo.jobStatus;
        }
        _currentHasBeenReviewed = roomInfo.hasBeenReviewed;

        _subscription = _repository
            .getMessages(_currentRoomId!)
            .listen((messages) => add(UpdateMessages(messages)));

        _jobStatusSubscription = _repository
            .getJobStatusEvents(_currentRoomId!)
            .listen((event) {
              final newStatus = event['new_status']?.toString();
              if (newStatus != null &&
                  newStatus.isNotEmpty &&
                  newStatus != _currentJobStatus) {
                _currentJobStatus = newStatus;
                if (state is ChatLoaded) {
                  final currentState = state as ChatLoaded;
                  emit(
                    ChatLoaded(
                      currentState.messages,
                      jobStatus: newStatus,
                      hasBeenReviewed: _currentHasBeenReviewed,
                    ),
                  );
                }
              }
            });
      } catch (e) {
        emit(ChatError('Lo sentimos, hubo un error en el chat.'));
      }
    });

    on<UpdateMessages>((event, emit) {
      if (_currentJobStatus == 'REQUESTED' || _currentJobStatus == null) {
        if (event.messages.isNotEmpty) {
          final lastMsg = event.messages.last;
          if (lastMsg.text.contains('Propuesta de visita aceptada')) {
            _currentJobStatus = 'AGREED';
          } else if (lastMsg.text.contains('Propuesta de visita rechazada') || lastMsg.text.contains('cancelada')) {
            _currentJobStatus = 'CANCELLED';
          } else if (!lastMsg.isMe && lastMsg.text.startsWith('Propuesta de visita:')) {
            _currentJobStatus = 'SCHEDULED';
          } else if (lastMsg.isMe && lastMsg.text.startsWith('Contraoferta de visita')) {
            _currentJobStatus = 'REQUESTED';
          }
        }
      }
      emit(
        ChatLoaded(
          event.messages,
          jobStatus: _currentJobStatus,
          hasBeenReviewed: _currentHasBeenReviewed,
          isSendingAttachment: _isSendingAttachment,
        ),
      );
    });

    on<TriggerJobCancelled>((event, emit) {
      _currentJobStatus = 'CANCELLED';
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        emit(ChatLoaded(currentState.messages, jobStatus: 'CANCELLED'));
      }
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
          await _repository.sendMessage(
            _currentRoomId!,
            'Propuesta de visita aceptada por el cliente.',
          );
          emit(JobAcceptedState());
        } catch (_) {}
      }
    });

    on<RejectJobProposal>((event, emit) async {
      if (_currentJobId != null && _currentRoomId != null) {
        try {
          final jobRepository = getIt<JobRepository>();
          final jobIdInt = int.parse(_currentJobId!);
          await jobRepository.updateJobStatus(
            jobIdInt,
            'CANCELLED',
            cancellationReason: event.cancellationReason,
          );
          _currentJobStatus = 'CANCELLED';
          if (state is ChatLoaded) {
            final currentState = state as ChatLoaded;
            emit(ChatLoaded(currentState.messages, jobStatus: 'CANCELLED'));
          }
          await _repository.sendMessage(
            _currentRoomId!,
            event.cancellationReason != null &&
                    event.cancellationReason!.isNotEmpty
                ? 'Propuesta de visita rechazada por el cliente. Motivo: ${event.cancellationReason}'
                : 'Propuesta de visita rechazada por el cliente.',
          );
        } catch (_) {}
      }
    });

    on<RenegotiateJobProposal>((event, emit) async {
      if (_currentJobId != null && _currentRoomId != null) {
        try {
          final jobRepository = getIt<JobRepository>();
          final jobIdInt = int.parse(_currentJobId!);
          await jobRepository.renegotiateJobPrice(
            jobIdInt,
            event.proposedPrice,
          );
          _currentJobStatus = 'REQUESTED';
          if (state is ChatLoaded) {
            final currentState = state as ChatLoaded;
            emit(ChatLoaded(currentState.messages, jobStatus: 'REQUESTED'));
          }
          await _repository.sendMessage(
            _currentRoomId!,
            'Contraoferta de visita | Precio: \$${event.proposedPrice.toInt()}',
          );
        } catch (_) {}
      }
    });

    on<SendMessage>((event, emit) async {
      if (_currentRoomId != null) {
        if (state is ChatLoaded && event.fileBase64 != null) {
          _isSendingAttachment = true;
          final currentState = state as ChatLoaded;
          emit(
            ChatLoaded(
              currentState.messages,
              jobStatus: _currentJobStatus,
              hasBeenReviewed: _currentHasBeenReviewed,
              isSendingAttachment: true,
            ),
          );
        }
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
        } finally {
          if (state is ChatLoaded && event.fileBase64 != null) {
            _isSendingAttachment = false;
            final currentState = state as ChatLoaded;
            emit(
              ChatLoaded(
                currentState.messages,
                jobStatus: _currentJobStatus,
                hasBeenReviewed: _currentHasBeenReviewed,
                isSendingAttachment: false,
              ),
            );
          }
        }
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _jobStatusSubscription?.cancel();
    return super.close();
  }
}
