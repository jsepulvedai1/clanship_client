import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/domain/repositories/home_repository.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:clanship_cliente/core/services/ugc_safety_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final HomeRepository homeRepository;
  final UgcSafetyService ugcSafetyService;
  VoidCallback? _safetyListener;

  FavoritesBloc(this.homeRepository, this.ugcSafetyService) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);

    _safetyListener = () {
      final blockedIds = ugcSafetyService.getBlockedUserIds();
      if (state is FavoritesLoaded) {
        final current = (state as FavoritesLoaded).favorites;
        final filtered = current.where((p) => !blockedIds.contains(p.id)).toList();
        if (filtered.length != current.length) {
          emit(FavoritesLoaded(filtered));
        }
      }
    };
    ugcSafetyService.blockedUserIdsNotifier.addListener(_safetyListener!);
  }

  @override
  Future<void> close() {
    if (_safetyListener != null) {
      ugcSafetyService.blockedUserIdsNotifier.removeListener(_safetyListener!);
    }
    return super.close();
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    final result = await homeRepository.getFavoriteProfessionals();
    result.fold(
      (failure) => emit(FavoritesFailure(failure.message)),
      (favorites) {
        final blockedIds = ugcSafetyService.getBlockedUserIds();
        final filtered = favorites.where((p) => !blockedIds.contains(p.id)).toList();
        emit(FavoritesLoaded(filtered));
      },
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
          final blockedIds = ugcSafetyService.getBlockedUserIds();
          List<Professional> updatedFavorites;
          if (isFavorite) {
            if (!currentFavorites.any((p) => p.id == event.professional.id) &&
                !blockedIds.contains(event.professional.id)) {
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
          add(LoadFavorites());
        }
      },
    );
  }
}
