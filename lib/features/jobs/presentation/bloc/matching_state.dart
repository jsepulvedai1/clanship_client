import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:equatable/equatable.dart';

abstract class MatchingState extends Equatable {
  final bool isExpanded;
  const MatchingState({this.isExpanded = false});

  @override
  List<Object?> get props => [isExpanded];
}

class MatchingIdle extends MatchingState {
  const MatchingIdle() : super(isExpanded: false);
}

class MatchingInProgress extends MatchingState {
  final Professional professional;

  const MatchingInProgress(this.professional, {super.isExpanded = false});

  MatchingInProgress copyWith({bool? isExpanded}) {
    return MatchingInProgress(professional, isExpanded: isExpanded ?? this.isExpanded);
  }

  @override
  List<Object?> get props => [professional, isExpanded];
}

class MatchingSuccess extends MatchingState {
  final Professional professional;

  const MatchingSuccess(this.professional, {super.isExpanded = false});

  @override
  List<Object?> get props => [professional, isExpanded];
}

class MatchingCancelled extends MatchingState {
  const MatchingCancelled() : super(isExpanded: false);
}
