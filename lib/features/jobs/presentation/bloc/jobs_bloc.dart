import 'dart:async';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final JobRepository _repository;
  StreamSubscription? _subscription;

  JobsBloc(this._repository) : super(JobsLoading()) {
    on<LoadJobs>(_onLoadJobs);
    on<AddJob>(_onAddJob);
    on<DeleteJob>(_onDeleteJob);
    on<UpdateJobsList>(_onUpdateJobsList);
    on<UpdateJobStatus>(_onUpdateJobStatus);
    
    _subscription = _repository.watchJobs().listen((jobs) {
      add(UpdateJobsList(jobs));
    });
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobsState> emit) async {
    emit(JobsLoading());
    try {
      final jobs = await _repository.getJobs();
      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(JobsError('Lo sentimos, hubo un error al cargar los trabajos.'));
    }
  }

  Future<void> _onAddJob(AddJob event, Emitter<JobsState> emit) async {
    await _repository.saveJob(event.job);
  }

  Future<void> _onDeleteJob(DeleteJob event, Emitter<JobsState> emit) async {
    await _repository.deleteJob(event.id);
  }

  void _onUpdateJobsList(UpdateJobsList event, Emitter<JobsState> emit) {
    emit(JobsLoaded(event.jobs));
  }

  Future<void> _onUpdateJobStatus(UpdateJobStatus event, Emitter<JobsState> emit) async {
    emit(JobsLoading());
    try {
      await _repository.updateJobStatus(int.parse(event.jobId), event.status);
      final jobs = await _repository.getJobs();
      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(JobsError('Lo sentimos, hubo un error al cargar los trabajos.'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
