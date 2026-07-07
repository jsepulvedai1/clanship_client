import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/pages/professional_documents_page.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/confirm_address_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:clanship_cliente/features/favorites/presentation/bloc/favorites_state.dart';

class ProfessionalDetailPage extends StatefulWidget {
  final Professional professional;

  const ProfessionalDetailPage({super.key, required this.professional});

  @override
  State<ProfessionalDetailPage> createState() => _ProfessionalDetailPageState();
}

class _ProfessionalDetailPageState extends State<ProfessionalDetailPage> {
  int _currentImageIndex = 0;

  void _createJobAndNavigate(BuildContext context, Professional professional, String address) async {
    final repository = getIt<JobRepository>();
    
    // Default values since the user doesn't fill a form yet
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";
    
    try {
      final jobId = await repository.createJob(
        int.parse(professional.id),
        formattedDate,
        formattedTime,
        "Trabajo solicitado desde el perfil",
        "0.00",
        address,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trabajo solicitado exitosamente')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              professional: professional,
              jobId: jobId,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el trabajo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Carousel with Rounded Corners
                Stack(
                  children: [
                    Hero(
                      tag: 'prof_${widget.professional.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: size.height * 0.45,
                            viewportFraction: 1.0,
                            enableInfiniteScroll:
                                widget.professional.galleryImages.length > 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                          ),
                          items:
                              (widget.professional.galleryImages.isNotEmpty
                                      ? widget.professional.galleryImages
                                      : [widget.professional.imageUrl])
                                  .map((url) {
                                    return CachedNetworkImage(
                                      imageUrl: url,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Theme.of(context).colorScheme.surface,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Theme.of(context).colorScheme.surface,
                                        child: const Center(
                                          child: Icon(
                                            Icons.error_outline_rounded,
                                            color: Colors.redAccent,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ),
                    // Carousel Indicators
                    if (widget.professional.galleryImages.length > 1)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.professional.galleryImages
                              .asMap()
                              .entries
                              .map((entry) {
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(
                                      _currentImageIndex == entry.key
                                          ? 0.9
                                          : 0.4,
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Rating Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.professional.name,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildRatingStars(widget.professional.rating),
                          const SizedBox(width: 8),
                          Text(
                            l10n.profDetailReviews(
                              widget.professional.rating.toInt().toString(),
                              '8',
                            ),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Distance
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.professional.distance.toInt()} km',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      Text(
                        widget.professional.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Social and Documents Row
                      Text(
                        l10n.profDetailFindMe,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSocialIcon(
                            FontAwesomeIcons.tiktok,
                            Theme.of(context).colorScheme.onSurface,
                            widget.professional.tiktokUrl,
                          ),
                          const SizedBox(width: 16),
                          _buildSocialIcon(
                            FontAwesomeIcons.facebook,
                            const Color(0xFF1877F2),
                            widget.professional.facebookUrl,
                          ),
                          const SizedBox(width: 16),
                          _buildSocialIcon(
                            FontAwesomeIcons.instagram,
                            const Color(0xFFE4405F),
                            widget.professional.instagramUrl,
                          ),
                          const Spacer(),
                          // Documents Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfessionalDocumentsPage(
                                    professional: widget.professional,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.visibility_outlined,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.profDetailDocuments,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Large Final Contact Button
                      Center(
                        child: BlocBuilder<JobsBloc, JobsState>(
                          builder: (context, jobsState) {
                            bool hasActiveJob = false;
                            if (jobsState is JobsLoaded) {
                              hasActiveJob = jobsState.jobs.any((job) =>
                                  job.professionalId == widget.professional.id &&
                                  (job.status == JobStatus.pending || job.status == JobStatus.accepted));
                            }

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (hasActiveJob) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(professional: widget.professional),
                                      ),
                                    );
                                  } else {
                                    ConfirmAddressBottomSheet.show(
                                      context,
                                      onConfirm: (confirmedAddress) {
                                        _createJobAndNavigate(
                                          context,
                                          widget.professional,
                                          confirmedAddress,
                                        );
                                      },
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  hasActiveJob ? l10n.jobsGoToChat : l10n.profDetailContact,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
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

          // Sticky Favorite Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                bool isFavorite = widget.professional.isFavorite;
                if (state is FavoritesLoaded) {
                  isFavorite = state.favorites.any((p) => p.id == widget.professional.id);
                }

                return CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  radius: 20,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      context.read<FavoritesBloc>().add(ToggleFavoriteEvent(widget.professional));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          size: 20,
          color: index < rating.floor() ? Colors.amber : Theme.of(context).dividerColor,
        );
      }),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, String? urlString) {
    final bool hasUrl = urlString != null && urlString.trim().isNotEmpty;
    return GestureDetector(
      onTap: hasUrl ? () => _launchURL(urlString) : null,
      child: Opacity(
        opacity: hasUrl ? 1.0 : 0.3,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasUrl ? color.withOpacity(0.1) : Colors.transparent,
          ),
          child: FaIcon(
            icon,
            color: hasUrl ? color : Colors.grey,
            size: 28,
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    String processedUrl = urlString.trim();
    if (!processedUrl.startsWith('http://') && !processedUrl.startsWith('https://')) {
      processedUrl = 'https://$processedUrl';
    }
    final Uri url = Uri.parse(processedUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir enlace: $e')),
        );
      }
    }
  }
}
