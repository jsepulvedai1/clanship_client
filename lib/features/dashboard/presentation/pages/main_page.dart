import 'dart:async';
import 'package:clanship_cliente/core/network/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/features/home/presentation/pages/home_page.dart';
import 'package:clanship_cliente/features/explore/presentation/pages/explore_map_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/jobs_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:clanship_cliente/features/favorites/presentation/pages/favorites_page.dart';
import 'package:clanship_cliente/features/settings/presentation/pages/settings_page.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/jobs_websocket_service.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_state.dart';
import 'package:clanship_cliente/core/utils/tutorial_keys.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    final socketService = getIt<JobsWebSocketService>();
    socketService.connect();
    _socketSubscription = socketService.stream.listen((event) {
      debugPrint('MainPage received jobs websocket notification: $event');

      try {
        final Map<String, dynamic> data = Map<String, dynamic>.from(event);
        final String rawEvent = data['event']?.toString() ?? data['type']?.toString() ?? '';
        final String eventType = rawEvent.toLowerCase();
        final String msgText = data['message']?.toString() ?? '';

        if (eventType == 'job_created' ||
            eventType == 'new_message' ||
            eventType == 'job_updated' ||
            eventType == 'job_status_changed' ||
            eventType == 'job_cancelled') {
          String title = 'Actualización de Solicitud';
          if (eventType == 'job_created') {
            title = 'Solicitud Creada';
          } else if (eventType == 'new_message') {
            title = 'Mensaje Nuevo';
          } else if (eventType == 'job_cancelled') {
            title = 'Solicitud Cancelada';
          } else if (eventType == 'job_updated' || eventType == 'job_status_changed') {
            title = 'Estado de Solicitud Actualizado';
          }

          LocalNotificationService.saveNotification(
            title,
            msgText.isNotEmpty ? msgText : 'Tienes una nueva actualización',
          );
        }
      } catch (_) {}

      if (mounted) {
        context.read<JobsBloc>().add(LoadJobs());
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, int>(
      listener: (context, currentIndex) {
        if (currentIndex == 1) {
          context.read<JobsBloc>().add(LoadJobs());
        } else if (currentIndex == 3) {
          context.read<FavoritesBloc>().add(LoadFavorites());
        }
      },
      child: BlocBuilder<NavigationBloc, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: [
                ExcludeSemantics(
                  excluding: currentIndex != 0,
                  child: const HomePage(),
                ),
                ExcludeSemantics(
                  excluding: currentIndex != 1,
                  child: const JobsPage(),
                ),
                ExcludeSemantics(
                  excluding: currentIndex != 2,
                  child: const ExploreMapPage(),
                ),
                ExcludeSemantics(
                  excluding: currentIndex != 3,
                  child: const FavoritesPage(),
                ),
                ExcludeSemantics(
                  excluding: currentIndex != 4,
                  child: const SettingsPage(),
                ),
              ],
            ),
            bottomNavigationBar: BlocBuilder<JobsBloc, JobsState>(
              builder: (context, jobsState) {
                final hasUnread =
                    jobsState is JobsLoaded &&
                    jobsState.jobs.any((job) => job.hasUnreadMessages);
                return _ClanshipBottomBar(
                  currentIndex: currentIndex,
                  hasUnreadJobs: hasUnread,
                  onTap: (index) {
                    context.read<NavigationBloc>().add(TabChanged(index));
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

class _ClanshipBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasUnreadJobs;

  const _ClanshipBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.hasUnreadJobs,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 70 + bottomPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: l10n.navHome,
              theme: theme,
              key: TutorialKeys.navInicioKey,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.work_outline_rounded,
              activeIcon: Icons.work_rounded,
              label: l10n.navJobs,
              theme: theme,
              showBadge: hasUnreadJobs,
              key: TutorialKeys.navJobsKey,
            ),
            GestureDetector(
              key: TutorialKeys.navExploreKey,
              onTap: () => onTap(2),
              child: _buildCenterButton(theme),
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.favorite_outline_rounded,
              activeIcon: Icons.favorite_rounded,
              label: l10n.navFavorites,
              theme: theme,
              key: TutorialKeys.navFavoritesKey,
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: l10n.navSettings,
              theme: theme,
              key: TutorialKeys.navSettingsKey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required ThemeData theme,
    bool showBadge = false,
    Key? key,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      key: key,
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: showBadge,
              largeSize: 20,
              smallSize: 9,
              backgroundColor: const Color(0xFFEF4444),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(ThemeData theme) {
    final isSelected = currentIndex == 2;
    return BlocBuilder<SeasonalThemeBloc, SeasonalThemeState>(
      builder: (context, seasonalState) {
        final centerColor = seasonalState.hasActiveCampaign
            ? seasonalState.navCenterColor
            : theme.colorScheme.primary;
        final iconUrl = seasonalState.navCenterIconUrl;

        return GestureDetector(
          onTap: () => onTap(2),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [centerColor, const Color(0xFF0066CC)]
                    : [centerColor.withValues(alpha: 0.9), centerColor],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: centerColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: (iconUrl != null && iconUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: iconUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.explore_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                    )
                  : Icon(
                      Icons.explore_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 28,
                    ),
            ),
          ),
        );
      },
    );
  }
}
