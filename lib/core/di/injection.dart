import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:clanship_cliente/core/di/injection.config.dart';

import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_cliente/core/theme/services/seasonal_theme_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
  if (!getIt.isRegistered<SeasonalThemeService>()) {
    getIt.registerLazySingleton<SeasonalThemeService>(() => SeasonalThemeService());
  }
  if (!getIt.isRegistered<SeasonalThemeBloc>()) {
    getIt.registerFactory<SeasonalThemeBloc>(() => SeasonalThemeBloc(getIt<SeasonalThemeService>()));
  }
}
