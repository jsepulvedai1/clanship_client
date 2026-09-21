import 'dart:ui';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/core/utils/error_parser.dart';
import 'package:clanship_cliente/core/utils/text_formatter.dart';
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
import 'package:clanship_cliente/core/services/ugc_safety_service.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';

class ProfessionalDetailPage extends StatefulWidget {
  final Professional professional;
  final String? heroTag;

  const ProfessionalDetailPage({
    super.key,
    required this.professional,
    this.heroTag,
  });

  @override
  State<ProfessionalDetailPage> createState() => _ProfessionalDetailPageState();
}

class _ProfessionalDetailPageState extends State<ProfessionalDetailPage> {
  int _currentImageIndex = 0;
  bool _showAllTags = false;

  List<Widget> _buildTagChipsWithLimit(List<String> tags) {
    if (tags.isEmpty) return [];

    if (tags.length <= 4) {
      return tags.map((tag) => _buildTagChip(tag)).toList();
    }

    if (!_showAllTags) {
      final visible = tags.take(4).map((tag) => _buildTagChip(tag)).toList();
      final remaining = tags.length - 4;
      visible.add(
        GestureDetector(
          onTap: () => setState(() => _showAllTags = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Text(
              '+$remaining más',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
      return visible;
    } else {
      final visible = tags.map((tag) => _buildTagChip(tag)).toList();
      visible.add(
        GestureDetector(
          onTap: () => setState(() => _showAllTags = false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: const Text(
              'Ver menos',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
      return visible;
    }
  }

  void _createJobAndNavigate(
    BuildContext context,
    Professional professional,
    String address,
  ) async {
    final repository = getIt<JobRepository>();

    // Default values since the user doesn't fill a form yet
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";

    try {
      final jobId = await repository.createJob(
        int.parse(professional.id),
        formattedDate,
        formattedTime,
        "Nueva solicitud de servicio",
        "0.00",
        address,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada exitosamente')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(professional: professional, jobId: jobId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al crear el trabajo: ${getCleanErrorMessage(e)}',
            ),
          ),
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
                SafeArea(
                  top: true,
                  bottom: false,
                  child: Stack(
                    children: [
                      Hero(
                        tag: widget.heroTag ?? 'prof_${widget.professional.id}',
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
                                ([
                                          if (widget
                                              .professional
                                              .imageUrl
                                              .isNotEmpty)
                                            widget.professional.imageUrl,
                                          ...widget.professional.galleryImages,
                                        ].isEmpty
                                        ? ['']
                                        : [
                                            if (widget
                                                .professional
                                                .imageUrl
                                                .isNotEmpty)
                                              widget.professional.imageUrl,
                                            ...widget
                                                .professional
                                                .galleryImages,
                                          ])
                                    .map((url) {
                                      return CachedNetworkImage(
                                        imageUrl: url,
                                        width: double.infinity,
                                        imageBuilder:
                                            (context, imageProvider) => Stack(
                                              children: [
                                                Image(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                                ClipRect(
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                      sigmaX: 15.0,
                                                      sigmaY: 15.0,
                                                    ),
                                                    child: Container(
                                                      color: Colors.black
                                                          .withValues(alpha: 0.15),
                                                    ),
                                                  ),
                                                ),
                                                Image(
                                                  image: imageProvider,
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ],
                                            ),
                                        placeholder: (context, url) =>
                                            Container(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surface,
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
                                      color: Colors.white.withValues(
                                        alpha: _currentImageIndex == entry.key
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
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
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
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Distance and tags inline wrap
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.professional.formattedDistance,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          ..._buildTagChipsWithLimit(widget.professional.tags),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      Text(
                        formatBioText(widget.professional.description),
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Social and Documents Row
                      Text(
                        l10n.profDetailFindMe,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                                  builder: (context) =>
                                      ProfessionalDocumentsPage(
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
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.visibility_outlined,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.profDetailDocuments,
                                    style: TextStyle(
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

                      const SizedBox(height: 20),
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
              backgroundColor: Colors.black.withValues(alpha: 0.3),
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

          // Sticky Action Buttons (Report & Favorite)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Block button
                CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.block_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    tooltip: 'Bloquear profesional',
                    onPressed: () => _showBlockDialog(context),
                  ),
                ),
                const SizedBox(width: 8),
                // Report button
                CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.flag_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Reportar perfil o fotos',
                    onPressed: () => _showReportDialog(context),
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite button
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    bool isFavorite = widget.professional.isFavorite;
                    if (state is FavoritesLoaded) {
                      isFavorite = state.favorites.any(
                        (p) => p.id == widget.professional.id,
                      );
                    }

                    return CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      radius: 20,
                      child: IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.redAccent : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          context.read<FavoritesBloc>().add(
                            ToggleFavoriteEvent(widget.professional),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 52,
            child: BlocBuilder<JobsBloc, JobsState>(
              builder: (context, jobsState) {
                bool hasActiveJob = false;
                if (jobsState is JobsLoaded) {
                  hasActiveJob = jobsState.jobs.any(
                    (job) =>
                        job.professionalId == widget.professional.id &&
                        (job.status == JobStatus.pending ||
                            job.status == JobStatus.accepted ||
                            job.status == JobStatus.scheduled),
                  );
                }

                return ElevatedButton(
                  onPressed: () {
                    if (hasActiveJob && jobsState is JobsLoaded) {
                      final activeJob = jobsState.jobs.firstWhere(
                        (job) =>
                            job.professionalId == widget.professional.id &&
                            (job.status == JobStatus.pending ||
                                job.status == JobStatus.accepted ||
                                job.status == JobStatus.scheduled),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            professional: widget.professional,
                            jobId: activeJob.id,
                          ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    hasActiveJob ? l10n.jobsGoToChat : l10n.profDetailContact,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          size: 20,
          color: index < rating.floor()
              ? Colors.amber
              : Theme.of(context).dividerColor,
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
            color: hasUrl ? color.withValues(alpha: 0.1) : Colors.transparent,
          ),
          child: FaIcon(icon, color: hasUrl ? color : Colors.grey, size: 28),
        ),
      ),
    );
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tagColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          color: tagColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    String processedUrl = urlString.trim();
    if (!processedUrl.startsWith('http://') &&
        !processedUrl.startsWith('https://')) {
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
          SnackBar(
            content: Text(
              'No se pudo abrir el enlace. Por favor, intenta de nuevo.',
            ),
          ),
        );
      }
    }
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.block_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¿Bloquear a ${widget.professional.name}?',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Al bloquear a este profesional:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• Se ocultará su perfil, fotos y ofertas de tus búsquedas de inmediato.',
                style: TextStyle(fontSize: 13, height: 1.3),
              ),
              SizedBox(height: 4),
              Text(
                '• No podrá contactarte ni enviarte presupuestos.',
                style: TextStyle(fontSize: 13, height: 1.3),
              ),
              SizedBox(height: 4),
              Text(
                '• Se enviará una notificación a nuestro equipo de soporte para revisar este usuario y actuar dentro de 24 horas según la política de Cero Tolerancia.',
                style: TextStyle(fontSize: 13, height: 1.3),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final navBloc = context.read<NavigationBloc>();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              await getIt<UgcSafetyService>().blockUser(
                userId: widget.professional.id,
                userName: widget.professional.name,
                reason: 'Bloqueado desde la vista de detalle de perfil',
              );

              navBloc.add(const TabChanged(0));
              navigator.popUntil((route) => route.isFirst);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Has bloqueado a ${widget.professional.name}. Este perfil ha sido ocultado de tus resultados y nuestro equipo actuará dentro de 24 horas.',
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Bloquear y Salir', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController detailController = TextEditingController();
    String selectedReason = 'Contenido inapropiado u ofensivo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reportar perfil o fotos de ${widget.professional.name}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el motivo por el cual deseas reportar este perfil o sus imágenes (revisión en 24h):',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    'Foto o imagen inapropiada / ofensiva',
                    'Spam o perfil falso',
                    'Información engañosa',
                    'Violación de derechos de autor',
                    'Otro motivo',
                  ].map(
                    (reason) => RadioListTile<String>(
                      title: Text(reason, style: const TextStyle(fontSize: 14)),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedReason = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Detalles adicionales (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        await getIt<UgcSafetyService>().reportContent(
                          targetId: widget.professional.id,
                          targetName: widget.professional.name,
                          reason: selectedReason,
                          details: detailController.text.trim(),
                          targetType: 'PROFILE_REPORT',
                        );
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Reporte recibido. Revisaremos las imágenes y el perfil en un plazo máximo de 24 horas y removeremos cualquier contenido objetable.',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: const Text(
                        'Enviar Reporte',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
