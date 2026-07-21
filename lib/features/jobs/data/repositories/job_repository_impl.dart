import 'dart:async';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: JobRepository)
class JobRepositoryImpl implements JobRepository {
  static const String _jobsBoxName = 'jobs_box';

  final GraphQLService _graphQLService;
  final _controller = StreamController<List<JobMatch>>.broadcast();

  JobRepositoryImpl(this._graphQLService);

  @override
  Future<String> createJob(
    int professionalId,
    String scheduledDate,
    String scheduledTime,
    String description,
    String agreedPrice,
    String address,
  ) async {
    const String mutation = r'''
      mutation CreateJob(
        $professionalId: Int!,
        $scheduledDate: Date!,
        $scheduledTime: Time!,
        $description: String!,
        $agreedPrice: Decimal!,
        $address: String!
      ) {
        createJob(
          professionalId: $professionalId
          scheduledDate: $scheduledDate
          scheduledTime: $scheduledTime
          description: $description
          agreedPrice: $agreedPrice
          address: $address
        ) {
          job {
            id
            status
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'professionalId': professionalId,
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'description': description,
        'agreedPrice': agreedPrice,
        'address': address,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final jobId = result.data?['createJob']?['job']?['id']?.toString();
    if (jobId == null) {
      throw Exception('Could not fetch new job ID');
    }

    // We could parse the response and add it to our local cache or just fetch again
    _updateStream();
    return jobId;
  }

  @override
  Future<List<JobMatch>> getJobs() async {
    const String query = r'''
      query GetMyJobs($status: String) {
        myJobs(status: $status) {
          id
          status
          scheduledDate
          scheduledTime
          description
          agreedPrice
          address
          hasUnreadMessages
          professional {
            id
            username
            firstName
            lastName
            avatarUrl
            professionalProfile {
              specialty {
                name
              }
              rating
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> jobsData = result.data?['myJobs'] as List<dynamic>? ?? [];
    final List<JobMatch> jobs = [];

    for (final jobData in jobsData) {
      try {
        final job = _mapGraphQLToJobMatch(jobData);
        jobs.add(job);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing job: $e');
        }
      }
    }

    // Sort by timestamp descending
    jobs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return jobs;
  }

  JobMatch _mapGraphQLToJobMatch(Map<String, dynamic> data) {
    JobStatus mapStatus(String? status) {
      switch (status) {
        case 'REQUESTED':
          return JobStatus.pending;
        case 'SCHEDULED':
          return JobStatus.scheduled;
        case 'AGREED':
        case 'IN_VISIT':
          return JobStatus.accepted;
        case 'FINISHED':
          return JobStatus.completed;
        case 'CANCELLED':
          return JobStatus.rejected;
        default:
          return JobStatus.pending;
      }
    }

    final professional = data['professional'] ?? {};
    
    String displayName = '';
    final String firstName = professional['firstName']?.toString() ?? '';
    final String lastName = professional['lastName']?.toString() ?? '';
    if (firstName.trim().isNotEmpty) {
      displayName = firstName.trim();
      if (lastName.trim().isNotEmpty) {
        displayName += ' ${lastName.trim()}';
      }
    } else {
      displayName = professional['username']?.toString() ?? 'Profesional';
    }

    DateTime timestamp = DateTime.now();
    try {
      if (data['scheduledDate'] != null) {
        timestamp = DateTime.parse('${data['scheduledDate']}T${data['scheduledTime'] ?? '00:00:00'}');
      }
    } catch (_) {}

    final profile = professional['professionalProfile'] ?? {};
    final specialty = profile['specialty'] ?? {};
    final specialtyName = specialty['name']?.toString() ?? 'General';
    final double ratingVal = double.tryParse(profile['rating']?.toString() ?? '5.0') ?? 5.0;

    return JobMatch(
      id: data['id']?.toString() ?? 'unknown',
      professionalId: professional['id']?.toString() ?? 'unknown',
      professionalName: displayName,
      professionalImageUrl: professional['avatarUrl']?.toString() ??
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=250&auto=format&fit=crop',
      professionalSpecialty: specialtyName,
      pricePerHour: 0.0,
      timestamp: timestamp,
      status: mapStatus(data['status']),
      rating: ratingVal,
      estimatedArrival: data['scheduledTime'],
      workDescription: data['description'],
      totalValue: double.tryParse(data['agreedPrice']?.toString() ?? '0'),
      hasUnreadMessages: data['hasUnreadMessages'] as bool? ?? false,
    );
  }

  @override
  Future<void> saveJob(JobMatch job) async {
    final box = await Hive.openBox(_jobsBoxName);
    await box.add(_toMap(job));
    _updateStream();
  }

  @override
  Future<void> deleteJob(String id) async {
    final box = await Hive.openBox(_jobsBoxName);
    final index = _findJobIndex(box, id);
    if (index != -1) {
      await box.deleteAt(index);
      _updateStream();
    }
  }

  @override
  Stream<List<JobMatch>> watchJobs() {
    _updateStream();
    return _controller.stream;
  }

  int _findJobIndex(Box box, String id) {
    for (var i = 0; i < box.length; i++) {
      final map = box.getAt(i) as Map;
      if (map['id'] == id) return i;
    }
    return -1;
  }

  Future<void> _updateStream() async {
    final jobs = await getJobs();
    _controller.add(jobs);
  }

  Map<String, dynamic> _toMap(JobMatch job) {
    return {
      'id': job.id,
      'professionalId': job.professionalId,
      'professionalName': job.professionalName,
      'professionalImageUrl': job.professionalImageUrl,
      'professionalSpecialty': job.professionalSpecialty,
      'pricePerHour': job.pricePerHour,
      'timestamp': job.timestamp.toIso8601String(),
      'status': job.status.index,
      'rating': job.rating,
      'estimatedArrival': job.estimatedArrival,
      'workDescription': job.workDescription,
      'totalValue': job.totalValue,
    };
  }

  JobMatch _fromMap(Map<String, dynamic> map) {
    return JobMatch(
      id: map['id'] ?? 'unknown',
      professionalId: map['professionalId'] ?? 'unknown',
      professionalName: map['professionalName'] ?? 'Unknown',
      professionalImageUrl: map['professionalImageUrl'] ?? '',
      professionalSpecialty: map['professionalSpecialty'] ?? '',
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      status: map['status'] != null
          ? JobStatus.values[map['status'] as int]
          : JobStatus.pending,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      estimatedArrival: map['estimatedArrival'],
      workDescription: map['workDescription'],
      totalValue: (map['totalValue'] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> enrichJob(
    int jobId,
    String enrichedDetails,
    String? photoBase64,
  ) async {
    const String mutation = r'''
      mutation EnrichJob($jobId: Int!, $enrichedDetails: String!, $photoBase64: String) {
        enrichJob(jobId: $jobId, enrichedDetails: $enrichedDetails, photoBase64: $photoBase64) {
          success
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'jobId': jobId,
        'enrichedDetails': enrichedDetails,
        'photoBase64': photoBase64,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  @override
  Future<void> updateJobStatus(int jobId, String status) async {
    const String mutation = r'''
      mutation UpdateJobStatus($jobId: Int!, $status: String!) {
        updateJobStatus(jobId: $jobId, newStatus: $status) {
          job {
            id
            status
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'jobId': jobId,
        'status': status,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    
    _updateStream();
  }

  @override
  Future<String> getJobStatus(int jobId) async {
    const String query = r'''
      query GetJob($id: Int!) {
        job(id: $id) {
          id
          status
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'id': jobId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final status = result.data?['job']?['status']?.toString();
    if (status == null) {
      throw Exception('Could not fetch job status');
    }

    return status;
  }
}
