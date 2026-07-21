import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:equatable/equatable.dart';

abstract class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobs extends JobsEvent {}

class AddJob extends JobsEvent {
  final JobMatch job;
  const AddJob(this.job);

  @override
  List<Object?> get props => [job];
}

class DeleteJob extends JobsEvent {
  final String id;
  const DeleteJob(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateJobsList extends JobsEvent {
  final List<JobMatch> jobs;
  const UpdateJobsList(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class UpdateJobStatus extends JobsEvent {
  final String jobId;
  final String status;
  const UpdateJobStatus(this.jobId, this.status);

  @override
  List<Object?> get props => [jobId, status];
}
