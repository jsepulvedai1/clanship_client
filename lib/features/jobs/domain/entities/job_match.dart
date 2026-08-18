import 'package:equatable/equatable.dart';

enum JobStatus {
  pending,
  scheduled,
  accepted,
  rejected,
  completed,
}

class JobMatch extends Equatable {
  final String id;
  final String professionalId;
  final String professionalName;
  final String professionalImageUrl;
  final String professionalSpecialty;
  final double pricePerHour;
  final DateTime timestamp;
  final JobStatus status;
  final double rating;
  final String? estimatedArrival;
  final String? workDescription;
  final double? totalValue;
  final bool hasUnreadMessages;
  final String? cancellationReason;
  final String? cancelledByUserName;
  final bool hasBeenReviewed;
  final int? givenRating;
  final String? reviewComment;

  const JobMatch({
    required this.id,
    required this.professionalId,
    required this.professionalName,
    required this.professionalImageUrl,
    required this.professionalSpecialty,
    required this.pricePerHour,
    required this.timestamp,
    this.status = JobStatus.pending,
    this.rating = 5.0,
    this.estimatedArrival,
    this.workDescription,
    this.totalValue,
    this.hasUnreadMessages = false,
    this.cancellationReason,
    this.cancelledByUserName,
    this.hasBeenReviewed = false,
    this.givenRating,
    this.reviewComment,
  });

  @override
  List<Object?> get props => [
        id,
        professionalId,
        professionalName,
        professionalImageUrl,
        professionalSpecialty,
        pricePerHour,
        timestamp,
        status,
        rating,
        estimatedArrival,
        workDescription,
        totalValue,
        hasUnreadMessages,
        cancellationReason,
        cancelledByUserName,
        hasBeenReviewed,
        givenRating,
        reviewComment,
      ];

  JobMatch copyWith({
    JobStatus? status,
    double? rating,
    String? estimatedArrival,
    String? workDescription,
    double? totalValue,
    bool? hasUnreadMessages,
    String? cancellationReason,
    String? cancelledByUserName,
    bool? hasBeenReviewed,
    int? givenRating,
    String? reviewComment,
  }) {
    return JobMatch(
      id: id,
      professionalId: professionalId,
      professionalName: professionalName,
      professionalImageUrl: professionalImageUrl,
      professionalSpecialty: professionalSpecialty,
      pricePerHour: pricePerHour,
      timestamp: timestamp,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      workDescription: workDescription ?? this.workDescription,
      totalValue: totalValue ?? this.totalValue,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledByUserName: cancelledByUserName ?? this.cancelledByUserName,
      hasBeenReviewed: hasBeenReviewed ?? this.hasBeenReviewed,
      givenRating: givenRating ?? this.givenRating,
      reviewComment: reviewComment ?? this.reviewComment,
    );
  }
}
