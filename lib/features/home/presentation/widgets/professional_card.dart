import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/pages/professional_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_state.dart';

class ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final VoidCallback? onTap;

  const ProfessionalCard({
    super.key,
    required this.professional,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfessionalDetailPage(professional: professional),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image: High Fidelity AspectRatio (match image reference)
              AspectRatio(
                aspectRatio: 1.1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: 'prof_${professional.id}',
                          child: professional.imageUrl.isNotEmpty
                              ? Image.network(
                                  professional.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.white,
                                    child: const Center(
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        size: 48,
                                        color: Color(0xFFBCC5D0),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.white,
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 48,
                                      color: Color(0xFFBCC5D0),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Favorite Badge Overlay (Premium Touch)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: BlocBuilder<FavoritesBloc, FavoritesState>(
                          builder: (context, state) {
                            bool isFavorite = professional.isFavorite;
                            if (state is FavoritesLoaded) {
                              isFavorite = state.favorites.any((p) => p.id == professional.id);
                            }

                            return GestureDetector(
                              onTap: () {
                                context.read<FavoritesBloc>().add(ToggleFavoriteEvent(professional));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFavorite ? Colors.redAccent : Colors.white,
                                  size: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Rating Badge Overlay (Premium Touch)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                professional.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Professional Name
              Text(
                professional.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Distance / Location Tag (matches reference color)
              Row(
                children: [
                   const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${professional.distance} km',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Description (Bio) matching the Lorem Ipsum in reference
              Expanded(
                child: Text(
                  professional.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    height: 1.4,
                    fontSize: 11,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
