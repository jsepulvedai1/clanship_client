import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/specialty_ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobTimelineCard extends StatelessWidget {
  final JobMatch job;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const JobTimelineCard({
    super.key,
    required this.job,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final statusConfig = _getStatusConfig(job.status);
    final dotColor = statusConfig.badgeColor;

    return Stack(
      children: [
        // Left Vertical Timeline Connector Line
        Positioned(
          left: 11,
          top: isFirst ? 26 : 0,
          bottom: isLast ? 26 : 0,
          child: Container(
            width: 2,
            color: dotColor.withValues(alpha: 0.22),
          ),
        ),

        // Timeline Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Dot
            SizedBox(
              width: 24,
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.35),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Card Container with Stacked Depth
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildCardWithStackedEffect(
                  context,
                  theme,
                  isDark,
                  statusConfig,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardWithStackedEffect(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    _JobStatusConfig statusConfig,
  ) {
    final cardBg = isDark ? theme.colorScheme.surface : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : theme.dividerColor.withValues(alpha: 0.2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Card
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : theme.shadowColor.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status Header Banner
                  _buildTopBanner(isDark, statusConfig),

                  // Card Content Body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar + Name + Date + Specialty
                        _buildHeaderRow(theme),
                        const SizedBox(height: 12),

                        // Work Description
                        Text(
                          job.workDescription != null &&
                                  job.workDescription!.trim().isNotEmpty
                              ? job.workDescription!
                              : 'Nueva solicitud de servicio',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : const Color(0xFF2E3135),
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        // 5 Star Rating
                        _buildRatingStars(theme),

                        // Rejection reason banner if rejected
                        if (job.status == JobStatus.rejected &&
                            job.cancellationReason != null &&
                            job.cancellationReason!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'Motivo: ${job.cancellationReason}',
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Divider
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : theme.dividerColor.withValues(alpha: 0.15),
                  ),

                  // Bottom Action Link: "VER DETALLES COMPLETOS"
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      'VER DETALLES COMPLETOS',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.accent
                            : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Stacked Card Bottom Depth Layers (Mockup multi-card effect)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          height: 3,
          decoration: BoxDecoration(
            color: cardBg.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border(
              left: BorderSide(color: borderColor, width: 0.8),
              right: BorderSide(color: borderColor, width: 0.8),
              bottom: BorderSide(color: borderColor, width: 0.8),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 2,
          decoration: BoxDecoration(
            color: cardBg.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            border: Border(
              left: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 0.6),
              right: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 0.6),
              bottom: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBanner(bool isDark, _JobStatusConfig statusConfig) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? statusConfig.badgeColor.withValues(alpha: 0.2)
            : statusConfig.bgTint,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(
            color: statusConfig.badgeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusConfig.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    final specialtyColor = SpecialtyUIHelper.getColor(
      job.professionalSpecialty,
    );
    final dateFormatted = DateFormat('dd MMM').format(job.timestamp);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with unread indicator
        Badge(
          isLabelVisible: job.hasUnreadMessages,
          backgroundColor: const Color(0xFFEF4444),
          smallSize: 8,
          child: _buildAvatar(specialtyColor),
        ),
        const SizedBox(width: 12),

        // Info (Name, Date, Specialty)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.professionalName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                job.professionalSpecialty.toUpperCase(),
                style: TextStyle(
                  color: specialtyColor == Colors.grey
                      ? AppColors.slate500
                      : specialtyColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(Color specialtyColor) {
    if (job.professionalImageUrl.isNotEmpty &&
        !job.professionalImageUrl.contains('unsplash.com')) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(job.professionalImageUrl),
      );
    }

    final nameParts = job.professionalName.trim().split(' ');
    String initials = '';
    if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      initials += nameParts[0][0];
    }
    if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
      initials += nameParts[1][0];
    }
    if (initials.isEmpty) initials = 'M';

    return CircleAvatar(
      radius: 22,
      backgroundColor: specialtyColor == Colors.grey
          ? AppColors.primary
          : specialtyColor,
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildRatingStars(ThemeData theme) {
    final ratingVal = job.rating;

    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < ratingVal.floor();
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            Icons.star_rounded,
            size: 18,
            color: isFilled
                ? const Color(0xFFFFB800)
                : theme.dividerColor.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }

  _JobStatusConfig _getStatusConfig(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return _JobStatusConfig(
          label: 'COTIZACIÓN',
          badgeColor: AppColors.primary,
          bgTint: const Color(0xFFD8F3EC),
        );
      case JobStatus.scheduled:
        return const _JobStatusConfig(
          label: 'EN CAMINO',
          badgeColor: Color(0xFFE86A38),
          bgTint: Color(0xFFFFE8D6),
        );
      case JobStatus.accepted:
        return const _JobStatusConfig(
          label: 'EN PROCESO',
          badgeColor: Color(0xFF0D2B45),
          bgTint: Color(0xFFD8EAF8),
        );
      case JobStatus.completed:
        return const _JobStatusConfig(
          label: 'FINALIZADO',
          badgeColor: Color(0xFF16A34A),
          bgTint: Color(0xFFDCFCE7),
        );
      case JobStatus.rejected:
        return const _JobStatusConfig(
          label: 'RECHAZADO',
          badgeColor: Color(0xFFEF4444),
          bgTint: Color(0xFFFFE4E6),
        );
    }
  }
}

class _JobStatusConfig {
  final String label;
  final Color badgeColor;
  final Color bgTint;

  const _JobStatusConfig({
    required this.label,
    required this.badgeColor,
    required this.bgTint,
  });
}
