import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_event.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_state.dart';
import 'package:clanship_cliente/core/theme/services/seasonal_theme_service.dart';

class SeasonalThemeBloc extends Bloc<SeasonalThemeEvent, SeasonalThemeState> {
  final SeasonalThemeService _service;

  SeasonalThemeBloc(this._service) : super(const SeasonalThemeState()) {
    on<LoadSeasonalTheme>(_onLoadSeasonalTheme);
    on<SeasonalThemeUpdated>((event, emit) {
      emit(state.copyWith(
        campaign: event.campaign,
        clearCampaign: event.campaign == null,
        isLoaded: true,
      ));
    });
  }

  Future<void> _onLoadSeasonalTheme(
    LoadSeasonalTheme event,
    Emitter<SeasonalThemeState> emit,
  ) async {
    // 1. Cargar caché inmediatamente para mostrar la festividad sin parpadeos
    final cached = await _service.getCachedCampaign();
    if (cached != null) {
      AppColors.setSeasonalOverrides(
        primary: cached.colors.primary,
        secondary: cached.colors.secondary,
        accent: cached.colors.accent,
      );
      emit(state.copyWith(campaign: cached, isLoaded: true));
    }

    // 2. Sincronizar en segundo plano la configuración fresca desde el backend
    try {
      final baseUrl = event.baseUrl ?? EnvConfig.instance.baseUrl;
      final fresh = await _service.fetchActiveCampaign(baseUrl: baseUrl);

      if (fresh != null) {
        AppColors.setSeasonalOverrides(
          primary: fresh.colors.primary,
          secondary: fresh.colors.secondary,
          accent: fresh.colors.accent,
        );
      } else {
        AppColors.resetDefaults();
      }

      emit(state.copyWith(
        campaign: fresh,
        clearCampaign: fresh == null,
        isLoaded: true,
      ));
    } catch (_) {
      // Si falla la red, el estado en caché ya emitido prevalece
    }
  }
}
