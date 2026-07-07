import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/features/home/presentation/pages/home_page.dart';
import 'package:clanship_cliente/features/explore/presentation/pages/explore_map_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/jobs_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/features/favorites/presentation/pages/favorites_page.dart';
import 'package:clanship_cliente/features/settings/presentation/pages/settings_page.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

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
              children: const [
                HomePage(),
                JobsPage(),
                ExploreMapPage(), // Center (index 2)
                FavoritesPage(),
                SettingsPage(),
              ],
            ),
            bottomNavigationBar: _ClanshipBottomBar(
              currentIndex: currentIndex,
              onTap: (index) {
                context.read<NavigationBloc>().add(TabChanged(index));
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

  const _ClanshipBottomBar({
    required this.currentIndex,
    required this.onTap,
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
            color: theme.shadowColor.withOpacity(0.06),
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
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.work_outline_rounded,
              activeIcon: Icons.work_rounded,
              label: l10n.navJobs,
              theme: theme,
            ),
            _buildCenterButton(theme),
            _buildNavItem(
              index: 3,
              icon: Icons.favorite_outline_rounded,
              activeIcon: Icons.favorite_rounded,
              label: l10n.navFavorites,
              theme: theme,
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: l10n.navSettings,
              theme: theme,
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
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(ThemeData theme) {
    final isSelected = currentIndex == 2;
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
                ? [AppColors.primary, const Color(0xFF0066CC)]
                : [AppColors.primary.withOpacity(0.85), AppColors.primary],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.explore_rounded,
          color: theme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }
}
