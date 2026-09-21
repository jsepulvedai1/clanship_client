import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:clanship_cliente/features/home/domain/repositories/home_repository.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_event.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_state.dart';
import 'package:clanship_cliente/core/services/ugc_safety_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;
  final UgcSafetyService ugcSafetyService;
  VoidCallback? _safetyListener;

  HomeBloc(this.homeRepository, this.ugcSafetyService) : super(HomeInitial()) {
    on<FetchNearbyProfessionals>(_onFetchNearbyProfessionals);
    on<SearchProfessionalsRequested>(_onSearchProfessionals);
    on<RemoveBlockedProfessional>(_onRemoveBlockedProfessional);

    _safetyListener = () {
      final blockedIds = ugcSafetyService.getBlockedUserIds();
      if (state is HomeLoaded) {
        final current = (state as HomeLoaded).professionals;
        final filtered = current.where((p) => !blockedIds.contains(p.id)).toList();
        if (filtered.length != current.length) {
          add(RemoveBlockedProfessional(blockedIds.lastOrNull ?? ''));
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

  void _onRemoveBlockedProfessional(
    RemoveBlockedProfessional event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final current = (state as HomeLoaded).professionals;
      final blockedIds = ugcSafetyService.getBlockedUserIds();
      final updated = current
          .where((p) => p.id != event.professionalId && !blockedIds.contains(p.id))
          .toList();
      emit(HomeLoaded(updated));
    }
  }

  Future<void> _onFetchNearbyProfessionals(
    FetchNearbyProfessionals event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final result = await homeRepository.getNearbyProfessionals(
      latitude: event.latitude,
      longitude: event.longitude,
      radius: event.radius,
    );
    result.fold(
      (failure) => emit(HomeFailure(failure.message)),
      (professionals) {
        final blockedIds = ugcSafetyService.getBlockedUserIds();
        final filtered = professionals.where((p) => !blockedIds.contains(p.id)).toList();
        emit(HomeLoaded(filtered));
      },
    );
  }

  Future<void> _onSearchProfessionals(
    SearchProfessionalsRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final result = await homeRepository.searchProfessionals(event.query);
    result.fold(
      (failure) => emit(HomeFailure(failure.message)),
      (professionals) {
        final blockedIds = ugcSafetyService.getBlockedUserIds();
        final filtered = professionals.where((p) => !blockedIds.contains(p.id)).toList();
        emit(HomeLoaded(filtered));
      },
    );
  }
}
