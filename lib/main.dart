import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:clanship_cliente/core/theme/app_theme.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_bloc.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_event.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_state.dart';
import 'package:clanship_cliente/core/settings/settings_repository.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/pages/login_page.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/firebase_options.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_state.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Required for App Distribution and other services)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint(
      'Make sure you have added google-services.json (Android) or GoogleService-Info.plist (iOS).',
    );
  }

  // Initialize dependency injection
  configureDependencies();

  // Initialize Global Settings Persistence (Hive)
  final settingsRepo = getIt<SettingsRepository>();
  await settingsRepo.init();

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
              themeMode: state.themeMode,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: state.locale,
              builder: (context, child) {
                return child ?? const SizedBox.shrink();
              },
              home: const LoginPage(),
            );
          },
        ),
      ),
    );
  }
}
