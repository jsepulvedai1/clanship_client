import 'package:clanship_cliente/core/config/app_startup.dart';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/theme/app_theme.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_bloc.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_event.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_state.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_state.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:clanship_cliente/features/splash/presentation/pages/splash_page.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_event.dart';

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

class ClanshipApp extends StatelessWidget {
  const ClanshipApp({super.key});

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
        BlocProvider(create: (context) => getIt<JobsBloc>()..add(LoadJobs())),
        BlocProvider(create: (context) => getIt<HomeBloc>()),
        BlocProvider(create: (context) => getIt<SplashBloc>()),
        BlocProvider(
          create: (context) => getIt<FavoritesBloc>()..add(LoadFavorites()),
        ),
      ],
      child: BlocListener<MatchingBloc, MatchingState>(
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
            final navBloc = context.read<NavigationBloc>();
            return MaterialApp(
              title: 'Clanship Cliente',
              navigatorKey: navBloc.navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
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
        ),
      ),
    );
  }
}
