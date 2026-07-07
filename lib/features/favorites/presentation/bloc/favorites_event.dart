import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final Professional professional;

  const ToggleFavoriteEvent(this.professional);

  @override
  List<Object?> get props => [professional];
}
