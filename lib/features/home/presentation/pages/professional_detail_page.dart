import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/matching_state.dart';

class ProfessionalDetailPage extends StatelessWidget {
  final Professional professional;

  const ProfessionalDetailPage({super.key, required this.professional});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header Image Section
                Hero(
                  tag: 'prof_${professional.id}',
                  child: Container(
                    height: size.height * 0.45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(professional.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Verified Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  professional.name,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  professional.specialty,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (professional.isVerified)
                            const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              radius: 18,
                              child: Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Social Media Links Row
                      _buildSocialLinks(context),

                      const SizedBox(height: 32),

                      // Stat Cards Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            context,
                            Icons.star_rounded,
                            professional.rating.toString(),
                            'Rating',
                            Colors.amber,
                          ),
                          _buildStatItem(
                            context,
                            Icons.location_on_rounded,
                            '${professional.distance} km',
                            'Distancia',
                            AppColors.primary,
                          ),
                          _buildStatItem(
                            context,
                            Icons.work_history_rounded,
                            '48+',
                            'Trabajos',
                            Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // About / Bio Section
                      Text(
                        l10n.profDetailAbout,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        professional.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(
                            0.7,
                          ),
                          height: 1.7,
                          letterSpacing: 0.3,
                        ),
                      ),

                      // Extra padding for the bottom fixed Bar
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.3),
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Fixed Bottom Hire Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tarifa por hora',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.textTheme.labelMedium?.color
                              ?.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${professional.pricePerHour.toInt()}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: BlocBuilder<MatchingBloc, MatchingState>(
                      builder: (context, state) {
                        final isMatching = state is MatchingInProgress;
                        return ElevatedButton(
                          onPressed: isMatching
                              ? null
                              : () => context.read<MatchingBloc>().add(
                                  StartInstantMatching(professional),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: isMatching ? 0 : 4,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                          ),
                          child: Text(
                            l10n.profDetailHire,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    final hasInstagram = professional.instagramUrl != null;
    final hasLinkedin = professional.linkedinUrl != null;
    final hasTwitter = professional.twitterUrl != null;

    if (!hasInstagram && !hasLinkedin && !hasTwitter)
      return const SizedBox.shrink();

    return Row(
      children: [
        if (hasInstagram)
          _buildSocialIcon(
            context,
            FontAwesomeIcons.instagram,
            professional.instagramUrl!,
            const Color(0xFFE4405F),
          ),
        if (hasLinkedin)
          _buildSocialIcon(
            context,
            FontAwesomeIcons.linkedinIn,
            professional.linkedinUrl!,
            const Color(0xFF0077B5),
          ),
        if (hasTwitter)
          _buildSocialIcon(
            context,
            FontAwesomeIcons.xTwitter,
            professional.twitterUrl!,
            Colors.black87,
          ),
      ],
    );
  }

  Widget _buildSocialIcon(
    BuildContext context,
    IconData icon,
    String url,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          // Future: launch URL via url_launcher
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: FaIcon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
