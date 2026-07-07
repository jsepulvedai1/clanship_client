import 'dart:async';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/domain/repositories/home_repository.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final HomeRepository homeRepository;

  FavoritesBloc(this.homeRepository) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    final result = await homeRepository.getFavoriteProfessionals();
    result.fold(
      (failure) => emit(FavoritesFailure(failure.message)),
      (favorites) => emit(FavoritesLoaded(favorites)),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await homeRepository.toggleFavorite(event.professional.id);
    result.fold(
      (failure) {
        // Silently fail or ignore, or we could emit error. Let's keep it smooth.
      },
      (isFavorite) {
        if (state is FavoritesLoaded) {
          final currentFavorites = (state as FavoritesLoaded).favorites;
          List<Professional> updatedFavorites;
          if (isFavorite) {
            if (!currentFavorites.any((p) => p.id == event.professional.id)) {
              updatedFavorites = List.from(currentFavorites)
                ..add(event.professional.copyWith(isFavorite: true));
            } else {
              updatedFavorites = currentFavorites;
            }
          } else {
            updatedFavorites =
                currentFavorites.where((p) => p.id != event.professional.id).toList();
          }
          emit(FavoritesLoaded(updatedFavorites));
        } else {
          // If state is not loaded (initial or failure), reload favorites to sync.
          add(LoadFavorites());
        }
      },
    );
  }
}
