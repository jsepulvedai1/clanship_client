import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/features/home/presentation/pages/home_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/jobs_page.dart';
import 'package:clanship_cliente/features/favorites/presentation/pages/favorites_page.dart';
import 'package:clanship_cliente/features/settings/presentation/pages/settings_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: const [
              HomePage(),
              JobsPage(),
              FavoritesPage(),
              SettingsPage(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              height: 65,
              elevation: 0,
              selectedIndex: currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              onDestinationSelected: (index) {
                context.read<NavigationBloc>().add(TabChanged(index));
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, size: 22),
                  selectedIcon: Icon(Icons.home, size: 22),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline, size: 22),
                  selectedIcon: Icon(Icons.work, size: 22),
                  label: 'Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_outline, size: 22),
                  selectedIcon: Icon(Icons.favorite, size: 22),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined, size: 22),
                  selectedIcon: Icon(Icons.settings, size: 22),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
