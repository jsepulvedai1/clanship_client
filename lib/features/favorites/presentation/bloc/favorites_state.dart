import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Professional> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

class FavoritesFailure extends FavoritesState {
  final String errorMessage;

  const FavoritesFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
