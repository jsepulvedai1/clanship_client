import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/dashboard/presentation/pages/main_page.dart';
import 'package:clanship_cliente/features/auth/presentation/pages/login_page.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_event.dart';
import 'package:clanship_cliente/features/splash/presentation/bloc/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/core/network/app_version_checker.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_event.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_state.dart';
import 'package:clanship_cliente/core/theme/widgets/seasonal_logo_badge.dart';
import 'package:clanship_cliente/core/theme/widgets/seasonal_particles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _checkVersionAndStart();
  }

  Future<void> _checkVersionAndStart() async {
    _animationController.forward();

    // Disparar carga de tema estacional inmediatamente en paralelo
    if (mounted) {
      final seasonalBloc = context.read<SeasonalThemeBloc>();
      if (!seasonalBloc.state.isLoaded) {
        seasonalBloc.add(
          LoadSeasonalTheme(baseUrl: EnvConfig.instance.baseUrl),
        );
      }
    }

    String currentVersion = '1.0.0';
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        currentVersion = info.version;
      }
    } catch (_) {}

    final bool isBlocked = await AppVersionChecker.checkVersion(
      context: context,
      appType: 'CLIENT',
      currentVersion: currentVersion,
      baseUrl: EnvConfig.instance.baseUrl,
    );

    if (!isBlocked && mounted) {
      context.read<SplashBloc>().add(AppStarted());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else if (state is SplashAuthenticated) {
          // Propagate the user info to AuthBloc
          context.read<AuthBloc>().add(UserAuthenticated(state.user));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      },
      child: BlocBuilder<SeasonalThemeBloc, SeasonalThemeState>(
        builder: (context, seasonalState) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: seasonalState.hasActiveCampaign
                      ? seasonalState.headerGradient
                      : [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: SeasonalParticlesOverlay(height: double.infinity),
                  ),
                  Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SeasonalLogoBadge(
                            badgeSize: 46,
                            offset: const Offset(13, -13),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.asset(
                                  'assets/icon/app_icon.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                const Text(
                  'ClanShip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Servicios Confiables a un Click',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 48),
                BlocBuilder<SplashBloc, SplashState>(
                  builder: (context, splashState) {
                    if (splashState is SplashConnectionError) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            splashState.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              context.read<SplashBloc>().add(AppStarted());
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar conexión'),
                          ),
                        ],
                      );
                    }
                    return const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
