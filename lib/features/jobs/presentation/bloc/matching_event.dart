import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:equatable/equatable.dart';

abstract class MatchingEvent extends Equatable {
  const MatchingEvent();

  @override
  List<Object?> get props => [];
}

class StartMatching extends MatchingEvent {
  final Professional professional;

  const StartMatching(this.professional);

  @override
  List<Object?> get props => [professional];
}

class StartInstantMatching extends MatchingEvent {
  final Professional professional;

  const StartInstantMatching(this.professional);

  @override
  List<Object?> get props => [professional];
}

class CancelMatching extends MatchingEvent {}

class CompleteMatching extends MatchingEvent {}

class ResetMatching extends MatchingEvent {}

class ToggleExpansion extends MatchingEvent {
  final bool isExpanded;
  const ToggleExpansion(this.isExpanded);

  @override
  List<Object?> get props => [isExpanded];
}
