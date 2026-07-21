import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';

abstract class JobRepository {
  Future<void> saveJob(JobMatch job);
  Future<List<JobMatch>> getJobs();
  Future<void> deleteJob(String id);
  Stream<List<JobMatch>> watchJobs();
  Future<String> createJob(
    int professionalId,
    String scheduledDate,
    String scheduledTime,
    String description,
    String agreedPrice,
    String address,
  );
  Future<void> enrichJob(
    int jobId,
    String enrichedDetails,
    String? photoBase64,
  );
  Future<void> updateJobStatus(
    int jobId,
    String status,
  );
  Future<String> getJobStatus(int jobId);
}
