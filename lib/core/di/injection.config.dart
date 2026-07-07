// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:clanship_cliente/core/di/external_libs_module.dart' as _i92;
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart'
    as _i457;
import 'package:clanship_cliente/core/network/graphql_service.dart' as _i12;
import 'package:clanship_cliente/core/network/location_service.dart' as _i369;
import 'package:clanship_cliente/core/persistence/database_helper.dart'
    as _i547;
import 'package:clanship_cliente/core/settings/bloc/settings_bloc.dart'
    as _i226;
import 'package:clanship_cliente/core/settings/settings_repository.dart'
    as _i85;
import 'package:clanship_cliente/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i774;
import 'package:clanship_cliente/features/auth/data/repositories/auth_repository_impl.dart'
    as _i246;
import 'package:clanship_cliente/features/auth/domain/repositories/auth_repository.dart'
    as _i1055;
import 'package:clanship_cliente/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i198;
import 'package:clanship_cliente/features/auth/domain/usecases/login_usecase.dart'
    as _i137;
import 'package:clanship_cliente/features/auth/domain/usecases/logout_usecase.dart'
    as _i542;
import 'package:clanship_cliente/features/auth/domain/usecases/register_usecase.dart'
    as _i1041;
import 'package:clanship_cliente/features/auth/domain/usecases/request_password_reset_usecase.dart'
    as _i87;
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart'
    as _i806;
import 'package:clanship_cliente/features/chat/data/repositories/chat_repository_impl.dart'
    as _i766;
import 'package:clanship_cliente/features/chat/domain/repositories/chat_repository.dart'
    as _i887;
import 'package:clanship_cliente/features/chat/presentation/bloc/chat_bloc.dart'
    as _i1058;
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_bloc.dart'
    as _i297;
import 'package:clanship_cliente/features/home/data/datasources/home_remote_data_source.dart'
    as _i22;
import 'package:clanship_cliente/features/home/data/repositories/home_repository_impl.dart'
    as _i667;
import 'package:clanship_cliente/features/home/domain/repositories/home_repository.dart'
    as _i600;
import 'package:clanship_cliente/features/home/presentation/bloc/home_bloc.dart'
    as _i536;
import 'package:clanship_cliente/features/jobs/data/repositories/job_repository_impl.dart'
    as _i663;
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart'
    as _i123;
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart'
    as _i156;
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_bloc.dart'
    as _i444;
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_bloc.dart'
    as _i380;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:graphql_flutter/graphql_flutter.dart' as _i128;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final externalLibsModule = _$ExternalLibsModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => externalLibsModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i85.SettingsRepository>(() => _i85.SettingsRepository());
    gh.lazySingleton<_i895.Connectivity>(() => externalLibsModule.connectivity);
    gh.lazySingleton<_i369.LocationService>(() => _i369.LocationService());
    gh.lazySingleton<_i12.GraphQLService>(() => _i12.GraphQLService());
    gh.lazySingleton<_i457.NavigationBloc>(() => _i457.NavigationBloc());
    gh.lazySingleton<_i547.DatabaseHelper>(() => _i547.DatabaseHelper());
    gh.lazySingleton<_i226.SettingsBloc>(
      () => _i226.SettingsBloc(gh<_i85.SettingsRepository>()),
    );
    gh.lazySingleton<_i128.GraphQLClient>(
      () => externalLibsModule.getGraphqlClient(gh<_i12.GraphQLService>()),
    );
    gh.lazySingleton<_i123.JobRepository>(
      () => _i663.JobRepositoryImpl(gh<_i12.GraphQLService>()),
    );
    gh.lazySingleton<_i887.ChatRepository>(
      () => _i766.ChatRepositoryImpl(gh<_i12.GraphQLService>()),
    );
    gh.lazySingleton<_i156.JobsBloc>(
      () => _i156.JobsBloc(gh<_i123.JobRepository>()),
    );
    gh.factory<_i1058.ChatBloc>(
      () => _i1058.ChatBloc(gh<_i887.ChatRepository>()),
    );
    gh.lazySingleton<_i774.AuthRemoteDataSource>(
      () => _i774.AuthRemoteDataSourceImpl(gh<_i128.GraphQLClient>()),
    );
    gh.lazySingleton<_i444.MatchingBloc>(
      () => _i444.MatchingBloc(gh<_i123.JobRepository>()),
    );
    gh.lazySingleton<_i22.HomeRemoteDataSource>(
      () => _i22.HomeRemoteDataSourceImpl(gh<_i128.GraphQLClient>()),
    );
    gh.lazySingleton<_i1055.AuthRepository>(
      () => _i246.AuthRepositoryImpl(gh<_i774.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i600.HomeRepository>(
      () => _i667.HomeRepositoryImpl(gh<_i22.HomeRemoteDataSource>()),
    );
    gh.factory<_i536.HomeBloc>(
      () => _i536.HomeBloc(gh<_i600.HomeRepository>()),
    );
    gh.factory<_i297.FavoritesBloc>(
      () => _i297.FavoritesBloc(gh<_i600.HomeRepository>()),
    );
    gh.lazySingleton<_i87.RequestPasswordResetUseCase>(
      () => _i87.RequestPasswordResetUseCase(gh<_i1055.AuthRepository>()),
    );
    gh.lazySingleton<_i1041.RegisterUseCase>(
      () => _i1041.RegisterUseCase(gh<_i1055.AuthRepository>()),
    );
    gh.lazySingleton<_i137.LoginUseCase>(
      () => _i137.LoginUseCase(gh<_i1055.AuthRepository>()),
    );
    gh.lazySingleton<_i542.LogoutUseCase>(
      () => _i542.LogoutUseCase(gh<_i1055.AuthRepository>()),
    );
    gh.lazySingleton<_i198.GetCurrentUserUseCase>(
      () => _i198.GetCurrentUserUseCase(gh<_i1055.AuthRepository>()),
    );
    gh.factory<_i380.SplashBloc>(
      () => _i380.SplashBloc(gh<_i198.GetCurrentUserUseCase>()),
    );
    gh.factory<_i806.AuthBloc>(
      () => _i806.AuthBloc(
        gh<_i137.LoginUseCase>(),
        gh<_i1041.RegisterUseCase>(),
        gh<_i542.LogoutUseCase>(),
        gh<_i87.RequestPasswordResetUseCase>(),
      ),
    );
    return this;
  }
}

class _$ExternalLibsModule extends _i92.ExternalLibsModule {}
