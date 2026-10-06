import 'package:flutter/material.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ServiceCategory {
  final String id;
  final String name;
  final IconData? icon;
  final String? iconUrl;
  final Color color;

  ServiceCategory({
    required this.id,
    required this.name,
    this.icon,
    this.iconUrl,
    required this.color,
  });
}

class ServiceCategoriesList extends StatelessWidget {
  final List<ServiceCategory> categories;
  final ValueChanged<ServiceCategory> onCategorySelected;
  final VoidCallback onViewAll;

  const ServiceCategoriesList({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorías de servicios',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'Ver todas',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 125,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 for the arrow/see all or just regular items
            itemBuilder: (context, index) {
              if (index == categories.length) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4, right: 24),
                  child: Center(
                    child: InkWell(
                      onTap: onViewAll,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: InkWell(
                  onTap: () => onCategorySelected(category),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: category.iconUrl!,
                                  width: 24,
                                  height: 24,
                                  errorWidget: (_, __, ___) => Icon(
                                    category.icon ?? Icons.category_rounded,
                                    color: category.color,
                                    size: 24,
                                  ),
                                )
                              : Icon(
                                  category.icon ?? Icons.category_rounded,
                                  color: category.color,
                                  size: 24,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
