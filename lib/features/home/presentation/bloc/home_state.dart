import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Professional> professionals;
  const HomeLoaded(this.professionals);

  @override
  List<Object?> get props => [professionals];
}

class HomeFailure extends HomeState {
  final String errorMessage;
  const HomeFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
