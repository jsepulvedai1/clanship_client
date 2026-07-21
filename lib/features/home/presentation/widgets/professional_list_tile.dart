import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/pages/professional_detail_page.dart';
import 'package:flutter/material.dart';

class ProfessionalListTile extends StatelessWidget {
  final Professional professional;
  final bool isUrgencyMode;

  const ProfessionalListTile({
    super.key,
    required this.professional,
    this.isUrgencyMode = false,
  });

  Widget _buildTagChip(String tag) {
    final parts = tag.split('|');
    final name = parts[0];
    final colorHex = parts.length > 1 ? parts[1] : null;

    Color tagColor = AppColors.primary; // fallback
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        final hex = colorHex.replaceAll('#', '');
        tagColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tagColor.withOpacity(0.2)),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          color: tagColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAvatar(Color primaryColor) {
    final hasImage = professional.imageUrl.isNotEmpty;
    final isNetwork = hasImage && (professional.imageUrl.startsWith('http://') || professional.imageUrl.startsWith('https://'));
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 80,
        color: primaryColor.withOpacity(0.1),
        child: hasImage
            ? (isNetwork
                ? Image.network(
                    professional.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(primaryColor),
                  )
                : Image.asset(
                    professional.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(primaryColor),
                  ))
            : _buildPlaceholder(primaryColor),
      ),
    );
  }

  Widget _buildPlaceholder(Color primaryColor) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        color: primaryColor,
        size: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = isUrgencyMode ? const Color(0xFFFF5271) : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfessionalDetailPage(professional: professional),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Profile Image/Avatar
              _buildAvatar(primaryColor),
              const SizedBox(width: 16),
              // Middle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            professional.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Rating Pill
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              professional.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Specialty
                    Text(
                      professional.specialty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Location & Distance
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: primaryColor, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          professional.formattedDistance,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // Tags wrap (only showing first 3 to prevent card from growing too large)
                    if (professional.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: professional.tags
                            .take(3)
                            .map((tag) => _buildTagChip(tag))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
