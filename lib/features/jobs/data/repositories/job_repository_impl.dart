import 'dart:async';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: JobRepository)
class JobRepositoryImpl implements JobRepository {
  static const String _jobsBoxName = 'jobs_box';
  
  final _controller = StreamController<List<JobMatch>>.broadcast();

  @override
  Future<List<JobMatch>> getJobs() async {
    final box = await Hive.openBox(_jobsBoxName);
    
    // Add mock data if empty for demonstration
    if (box.isEmpty) {
      final now = DateTime.now();
      final mockJobs = [
        JobMatch(
          id: 'mock_1',
          professionalId: '1',
          professionalName: 'Julián',
          professionalImageUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=250&auto=format&fit=crop',
          professionalSpecialty: 'Fontanero',
          pricePerHour: 15000.0,
          timestamp: now,
          status: JobStatus.accepted,
          rating: 4.0,
          estimatedArrival: '00:00 Hrs.',
          workDescription: 'Reparación de filtración en cocina y cambio de grifería. El trabajo requiere materiales básicos incluidos.',
          totalValue: 35000.0,
        ),
        JobMatch(
          id: 'mock_2',
          professionalId: '1',
          professionalName: 'Julián',
          professionalImageUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=250&auto=format&fit=crop',
          professionalSpecialty: 'Fontanero (Emergencia)',
          pricePerHour: 25000.0,
          timestamp: now.subtract(const Duration(minutes: 30)),
          status: JobStatus.accepted,
          rating: 5.0,
          estimatedArrival: '00:00 Hrs.',
          workDescription: 'Emergencia por rotura de cañería principal. Intervención inmediata requerida.',
          totalValue: 45000.0,
        ),
        JobMatch(
          id: 'mock_3',
          professionalId: '3',
          professionalName: 'Pablo',
          professionalImageUrl: 'https://images.unsplash.com/photo-1540569014015-19a7ee504e1a?q=80&w=250&auto=format&fit=crop',
          professionalSpecialty: 'Carpintero',
          pricePerHour: 12000.0,
          timestamp: DateTime(2026, 1, 1),
          status: JobStatus.completed,
          rating: 4.0,
          workDescription: 'Instalación de repisas decorativas y ajuste de puerta principal.',
          totalValue: 28000.0,
        ),
      ];
      for (final job in mockJobs) {
        await box.add(_toMap(job));
      }
    }

    final List<JobMatch> jobs = [];
    
    for (var i = 0; i < box.length; i++) {
      try {
        final map = Map<String, dynamic>.from(box.getAt(i) as Map);
        // Field validation to skip corrupted entries
        if (map['id'] == null || map['professionalName'] == null) continue;
        
        jobs.add(_fromMap(map));
      } catch (e) {
        if (kDebugMode) {
          print('Skipping corrupted job entry at index $i: $e');
        }
        continue;
      }
    }
    
    // Sort by timestamp descending
    jobs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return jobs;
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
}
