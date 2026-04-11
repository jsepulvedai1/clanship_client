import 'dart:async';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class MatchingBloc extends Bloc<MatchingEvent, MatchingState> {
  final JobRepository _jobRepository;
  Timer? _matchingTimer;
  final _uuid = const Uuid();

  MatchingBloc(this._jobRepository) : super(MatchingIdle()) {
    on<StartMatching>(_onStartMatching);
    on<StartInstantMatching>(_onStartInstantMatching);
    on<CancelMatching>(_onCancelMatching);
    on<CompleteMatching>(_onCompleteMatching);
    on<ResetMatching>(_onResetMatching);
    on<ToggleExpansion>(_onToggleExpansion);
  }

  void _onStartMatching(StartMatching event, Emitter<MatchingState> emit) {
    _matchingTimer?.cancel();
    emit(MatchingInProgress(event.professional));

    // Simulate backend matching delay - Increased to 10 seconds
    _matchingTimer = Timer(const Duration(seconds: 10), () {
      add(CompleteMatching());
    });
  }

  void _onStartInstantMatching(StartInstantMatching event, Emitter<MatchingState> emit) {
    _matchingTimer?.cancel();
    
    // Create and persist the Job instantly
    final job = JobMatch(
      id: _uuid.v4(),
      professionalId: event.professional.id,
      professionalName: event.professional.name,
      professionalImageUrl: event.professional.imageUrl,
      professionalSpecialty: event.professional.specialty,
      pricePerHour: event.professional.pricePerHour,
      timestamp: DateTime.now(),
      status: JobStatus.accepted,
    );
    
    _jobRepository.saveJob(job);
    
    emit(MatchingSuccess(event.professional));
  }

  void _onCancelMatching(CancelMatching event, Emitter<MatchingState> emit) {
    _matchingTimer?.cancel();
    emit(MatchingCancelled());
    // Auto-reset after showing cancellation feedback if needed, but for now just idle
    Future.delayed(const Duration(seconds: 1), () {
      add(ResetMatching());
    });
  }

  void _onCompleteMatching(CompleteMatching event, Emitter<MatchingState> emit) {
    if (state is MatchingInProgress) {
      final inProgress = state as MatchingInProgress;
      final professional = inProgress.professional;
      
      // Create and persist the Job
      final job = JobMatch(
        id: _uuid.v4(),
        professionalId: professional.id,
        professionalName: professional.name,
        professionalImageUrl: professional.imageUrl,
        professionalSpecialty: professional.specialty,
        pricePerHour: professional.pricePerHour,
        timestamp: DateTime.now(),
        status: JobStatus.accepted,
      );
      
      _jobRepository.saveJob(job);
      
      emit(MatchingSuccess(professional, isExpanded: inProgress.isExpanded));
    }
  }

  void _onToggleExpansion(ToggleExpansion event, Emitter<MatchingState> emit) {
    if (state is MatchingInProgress) {
      emit((state as MatchingInProgress).copyWith(isExpanded: event.isExpanded));
    }
  }

  void _onResetMatching(ResetMatching event, Emitter<MatchingState> emit) {
    emit(MatchingIdle());
  }

  @override
  Future<void> close() {
    _matchingTimer?.cancel();
    return super.close();
  }
}
