import 'package:clanship_cliente/core/settings/bloc/settings_bloc.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_event.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_state.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Determine if the current theme is Dark based on the provided state
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final isDark = state.themeMode == ThemeMode.dark;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.settingsTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
              // Appearance Section
              _buildSectionHeader(theme, l10n.settingsAppearance),
              const SizedBox(height: 16),
              _buildSettingCard(
                theme,
                child: SwitchListTile(
                  title: Text(
                    l10n.settingsDarkMode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? 'Fondo negro puro activo' : 'Activar fondo AMOLED',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? theme.colorScheme.primary : null,
                    ),
                  ),
                  value: isDark,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      UpdateTheme(value ? ThemeMode.dark : ThemeMode.light),
                    );
                  },
                  activeColor: theme.colorScheme.primary,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Language Section
              _buildSectionHeader(theme, l10n.settingsLanguage),
              const SizedBox(height: 16),
              _buildSettingCard(
                theme,
                child: Column(
                  children: [
                    _buildLanguageOption(
                      context,
                      theme,
                      label: l10n.settingsSpanish,
                      locale: const Locale('es'),
                      isSelected: state.locale.languageCode == 'es',
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 16),
                    _buildLanguageOption(
                      context,
                      theme,
                      label: l10n.settingsEnglish,
                      locale: const Locale('en'),
                      isSelected: state.locale.languageCode == 'en',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // App Info (Visual Polish)
              Center(
                child: Column(
                  children: [
                    Opacity(
                      opacity: 0.3,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ClanShip v1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSettingCard(ThemeData theme, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.03 : 0.2,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    ThemeData theme, {
    required String label,
    required Locale locale,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isSelected ? theme.colorScheme.primary : Colors.grey)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.translate_rounded,
          color: isSelected ? theme.colorScheme.primary : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        context.read<SettingsBloc>().add(UpdateLocale(locale));
      },
    );
  }
}
