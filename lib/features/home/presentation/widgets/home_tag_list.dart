import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HomeTagList extends StatelessWidget {
  final List<String> tags;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback? onViewAll;

  const HomeTagList({
    super.key,
    required this.tags,
    required this.selectedIndex,
    required this.onSelected,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tags Row (Occupying available space)
          Expanded(
            child: Row(
              children: tags.asMap().entries.map((entry) {
                final index = entry.key;
                final label = entry.value;
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => onSelected(index),
                      borderRadius: BorderRadius.circular(25),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // View All Link
          if (onViewAll != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   l10n.homeViewAll,
                    //   style: theme.textTheme.labelLarge?.copyWith(
                    //     color: theme.colorScheme.primary,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(width: 4),
                    // Icon(
                    //   Icons.chevron_right_rounded,
                    //   color: theme.colorScheme.primary,
                    //   size: 22,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
