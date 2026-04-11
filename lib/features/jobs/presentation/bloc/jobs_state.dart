import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:equatable/equatable.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<JobMatch> jobs;
  const JobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobsError extends JobsState {
  final String message;
  const JobsError(this.message);

  @override
  List<Object?> get props => [message];
}
