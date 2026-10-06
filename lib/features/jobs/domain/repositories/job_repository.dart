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
    String status, {
    String? cancellationReason,
  });
  Future<void> rateJob(
    int jobId,
    int rating,
    String? comment,
  );
  Future<String> getJobStatus(int jobId);
  Future<bool> createPublicJobRequest({
    int? specialtyId,
    String? customSpecialty,
    required String title,
    required String description,
    required String address,
    double? latitude,
    double? longitude,
    double? budget,
    bool isUrgent = false,
    String? desiredDate,
    List<String>? photosBase64,
  });
  Future<List<Map<String, dynamic>>> getMyPublicJobRequests();
  Future<bool> acceptJobProposal(int proposalId);
  Future<bool> cancelPublicJobRequest(int requestId);
  Future<void> renegotiateJobPrice(int jobId, double proposedPrice);
  Future<void> createJobClaim(int jobId, String details);
}
