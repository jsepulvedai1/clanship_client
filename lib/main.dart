import 'dart:async';
import 'package:clanship_cliente/core/config/shorebird_update_manager.dart';
import 'package:clanship_cliente/core/config/app_startup.dart';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/core/theme/app_theme.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_bloc.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_event.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_state.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/pages/login_page.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/network/session_service.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_state.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:clanship_cliente/features/splash/presentation/pages/splash_page.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_event.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_state.dart';

void main() async {
  await AppStartup.init();

  // Default to Prod if run directly
  EnvConfig.instantiate(
    environment: Environment.prod,
    baseUrl: 'https://api.clanship.cl/graphql/',
    websocketUrl: 'wss://api.clanship.cl/graphql/',
  );

  runApp(const ClanshipApp());
}

class ClanshipApp extends StatefulWidget {
  const ClanshipApp({super.key});

  @override
  State<ClanshipApp> createState() => _ClanshipAppState();
}

class _ClanshipAppState extends State<ClanshipApp> with WidgetsBindingObserver {
  StreamSubscription<String>? _sessionSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final context = getIt<NavigationBloc>().navigatorKey.currentContext;
      if (context != null) {
        ShorebirdUpdateManager.checkForUpdate(context);
      }
    }
  }

  void _listenSessionInvalidation(BuildContext context) {
    _sessionSub?.cancel();
    _sessionSub = SessionService.instance.onSessionInvalidated.listen((reason) {
      // Forzar logout en el AuthBloc
      if (context.mounted) {
        context.read<AuthBloc>().add(LogoutRequested());
      }
      
      // Reset navigation state to tab 0
      getIt<NavigationBloc>().add(const TabChanged(0));

      // Navegar a LoginPage limpiando toda la pila de navegación
      final navigator = getIt<NavigationBloc>().navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );

        // Mostrar mensaje al usuario
        ScaffoldMessenger.of(navigator.context).showSnackBar(
          SnackBar(
            content: Text(reason),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SettingsBloc>()..add(LoadSettings()),
        ),
        BlocProvider(create: (context) => getIt<NavigationBloc>()),
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<MatchingBloc>()),
        BlocProvider(create: (context) => getIt<JobsBloc>()),
        BlocProvider(create: (context) => getIt<HomeBloc>()),
        BlocProvider(create: (context) => getIt<SplashBloc>()),
        BlocProvider(create: (context) => getIt<FavoritesBloc>()),
        BlocProvider(
          create: (context) => getIt<SeasonalThemeBloc>()..add(const LoadSeasonalTheme()),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Iniciar listener de sesión invalidada una vez que los blocs están disponibles
          _listenSessionInvalidation(context);

          return BlocListener<MatchingBloc, MatchingState>(
            listener: (context, state) {
              if (state is MatchingSuccess) {
                // Navigate to Jobs tab (index 1) on success
                context.read<NavigationBloc>().add(const TabChanged(1));

                // Navigate to ChatPage
                Future.microtask(() {
                  final navigator = context
                      .read<NavigationBloc>()
                      .navigatorKey
                      .currentState;
                  navigator?.push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatPage(professional: state.professional),
                    ),
                  );
                });

                // Auto-reset after a short delay
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    context.read<MatchingBloc>().add(ResetMatching());
                  }
                });
              }
            },
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return BlocBuilder<SeasonalThemeBloc, SeasonalThemeState>(
                  builder: (context, seasonalState) {
                    final navBloc = context.read<NavigationBloc>();

                    // Sincronizar paleta global centralizada AppColors con el estado de la temporada
                    if (seasonalState.hasActiveCampaign) {
                      AppColors.setSeasonalOverrides(
                        primary: seasonalState.primaryColor,
                        secondary: seasonalState.secondaryColor,
                        accent: seasonalState.accentColor,
                      );
                    } else {
                      AppColors.resetDefaults();
                    }

                    final lightTheme = AppTheme.buildLightTheme(
                      primary: seasonalState.primaryColor,
                      secondary: seasonalState.secondaryColor,
                      accent: seasonalState.accentColor,
                    );
                    final darkTheme = AppTheme.buildDarkTheme(
                      primary: seasonalState.primaryColor,
                      secondary: seasonalState.secondaryColor,
                      accent: seasonalState.accentColor,
                    );

                    return MaterialApp(
                      title: 'Clanship Cliente',
                      navigatorKey: navBloc.navigatorKey,
                      debugShowCheckedModeBanner: false,
                      theme: lightTheme,
                      darkTheme: darkTheme,
                      themeMode: ThemeMode.light,
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      locale: state.locale,
                      builder: (context, child) {
                        return child ?? const SizedBox.shrink();
                      },
                      home: const SplashPage(),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
