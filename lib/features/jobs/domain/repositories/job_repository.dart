import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';

abstract class JobRepository {
  Future<void> saveJob(JobMatch job);
  Future<List<JobMatch>> getJobs();
  Future<void> deleteJob(String id);
  Stream<List<JobMatch>> watchJobs();
}
