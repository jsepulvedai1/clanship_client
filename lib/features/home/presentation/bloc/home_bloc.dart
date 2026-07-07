import 'dart:async';
import 'package:clanship_cliente/features/home/domain/repositories/home_repository.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_event.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc(this.homeRepository) : super(HomeInitial()) {
    on<FetchNearbyProfessionals>(_onFetchNearbyProfessionals);
    on<SearchProfessionalsRequested>(_onSearchProfessionals);
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
      (professionals) => emit(HomeLoaded(professionals)),
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
      (professionals) => emit(HomeLoaded(professionals)),
    );
  }
}
