import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/rating_dialog.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/create_job_claim_dialog.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/specialty_ui_helper.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/utils/currency_formatter.dart';

class JobDetailPage extends StatelessWidget {
  final JobMatch job;

  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final bool hasDescription =
        job.workDescription != null && job.workDescription!.trim().isNotEmpty;
    final bool hasPrice = job.totalValue != null && job.totalValue! > 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.jobsDetailTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor:
            theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onSurface,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildStatusBadge(job.status, l10n, theme),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Professional Hero Card
                  _buildProfessionalCard(theme, l10n),
                  const SizedBox(height: 20),

                  // Scheduled Proposal Card
                  if (job.status == JobStatus.scheduled) ...[
                    _buildProposalCard(context, theme, l10n),
                    const SizedBox(height: 20),
                  ],

                  // Rejection / Cancellation Card
                  if (job.status == JobStatus.rejected) ...[
                    _buildRejectionCard(theme, l10n),
                    const SizedBox(height: 20),
                  ],

                  // Rating Section for Completed Jobs
                  if (job.status == JobStatus.completed) ...[
                    if (job.finalPrice != null || (job.tradesmanComments != null && job.tradesmanComments!.isNotEmpty) || (job.finishedPhotosUrls != null && job.finishedPhotosUrls!.isNotEmpty)) ...[
                      _buildFinishedDetailsSection(context, theme, l10n),
                      const SizedBox(height: 20),
                    ],

                    _buildRatingSection(context, theme, l10n),
                    const SizedBox(height: 20),
                    _buildClaimSection(context, theme),
                    const SizedBox(height: 20),
                  ],

                  // Job Description (Only if not empty)
                  if (hasDescription) ...[
                    _buildSectionHeader(
                      title: l10n.jobsDescription,
                      icon: Icons.description_outlined,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildContentCard(
                      theme: theme,
                      child: Text(
                        job.workDescription!.trim(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Pricing Section (Only if not null / > 0)
                  if (hasPrice) ...[
                    _buildSectionHeader(
                      title: l10n.jobsTotalValue,
                      icon: Icons.payments_outlined,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildPriceCard(theme, l10n),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Action Buttons Footer
          _buildActionFooter(context, l10n, theme),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    JobStatus status,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case JobStatus.pending:
        badgeColor = AppColors.accent;
        statusText = l10n.jobsStatusPending;
        break;
      case JobStatus.scheduled:
        badgeColor = Colors.deepOrange;
        statusText = l10n.jobsInProcess;
        break;
      case JobStatus.accepted:
        badgeColor = AppColors.primary;
        statusText = l10n.jobsStatusActive;
        break;
      case JobStatus.completed:
        badgeColor = AppColors.success;
        statusText = l10n.jobsStatusCompleted;
        break;
      case JobStatus.rejected:
        badgeColor = AppColors.urgency;
        statusText = l10n.jobsStatusRejected;
        break;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard({required Widget child, required ThemeData theme}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProfessionalCard(ThemeData theme, AppLocalizations l10n) {
    final specialtyTags = _extractSpecialtyTags(job.professionalSpecialty);
    final hasArrival = job.estimatedArrival != null &&
        job.estimatedArrival!.trim().isNotEmpty &&
        job.estimatedArrival!.trim() != '...';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Fallback
              Hero(
                tag: 'job_prof_${job.id}',
                child: _buildAvatar(theme),
              ),
              const SizedBox(width: 14),

              // Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.professionalName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                job.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasArrival) ...[
                          const SizedBox(width: 8),
                          _buildArrivalChip(theme),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Specialty Tags (Only rendered if tags exist and are non-empty)
          if (specialtyTags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: specialtyTags.map((tag) => _buildSpecialtyChip(tag, theme)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _extractSpecialtyTags(String? specialty) {
    if (specialty == null || specialty.trim().isEmpty) {
      return [];
    }
    return specialty
        .split(RegExp(r'[,/|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.toLowerCase() != 'general')
        .toList();
  }

  Widget _buildSpecialtyChip(String tag, ThemeData theme) {
    final color = SpecialtyUIHelper.getColor(tag);
    final icon = SpecialtyUIHelper.getIcon(tag);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            tag,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            job.estimatedArrival!.trim(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final bool hasValidNetworkImage = job.professionalImageUrl.isNotEmpty &&
        !job.professionalImageUrl.contains('unsplash.com');

    if (hasValidNetworkImage) {
      return Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            job.professionalImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildAvatarFallback(),
          ),
        ),
      );
    }

    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    final nameParts = job.professionalName.trim().split(' ');
    String initials = '';
    if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      initials += nameParts[0][0];
    }
    if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
      initials += nameParts[1][0];
    }
    if (initials.isEmpty) initials = 'M';

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(ThemeData theme, AppLocalizations l10n) {
    final value = job.totalValue ?? 0.0;

    return _buildContentCard(
      theme: theme,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.jobsTotal,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          Text(
            '${formatCurrency(value)} CLP',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final arrival = (job.estimatedArrival != null &&
            job.estimatedArrival!.trim().isNotEmpty &&
            job.estimatedArrival!.trim() != '...')
        ? job.estimatedArrival!.trim()
        : l10n.jobsInProcess;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Colors.orange,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.jobsVisitProposalTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.jobsVisitProposalDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Colors.deepOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  arrival,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionCard(ThemeData theme, AppLocalizations l10n) {
    final byWho = job.cancelledByUserName != null &&
            job.cancelledByUserName!.trim().isNotEmpty
        ? l10n.jobsRejectedBy(job.cancelledByUserName!.trim())
        : l10n.jobsRejectedDefault;

    final bool hasReason = job.cancellationReason != null &&
        job.cancellationReason!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.urgency.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.urgency.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel_outlined,
                color: AppColors.urgency,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  byWho,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
          if (hasReason) ...[
            const SizedBox(height: 10),
            Text(
              l10n.jobsRejectionReason,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF991B1B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              job.cancellationReason!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, AppLocalizations l10n) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.jobsRejectDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.jobsRejectReasonOptional,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.jobsReasonHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.urgency,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              Navigator.pop(dialogContext);
              context.read<JobsBloc>().add(
                    UpdateJobStatus(
                      job.id,
                      'CANCELLED',
                      cancellationReason: reason.isNotEmpty ? reason : null,
                    ),
                  );
              Navigator.pop(context);
            },
            child: Text(l10n.jobsRejectConfirm),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppLocalizations l10n) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.jobsCancelDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.jobsCancelDialogMsg,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.jobsCancelReasonLabel,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.jobsReasonHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.urgency,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              Navigator.pop(dialogContext);
              context.read<JobsBloc>().add(
                    UpdateJobStatus(
                      job.id,
                      'CANCELLED',
                      cancellationReason: reason.isNotEmpty ? reason : null,
                    ),
                  );
              Navigator.pop(context);
            },
            child: Text(l10n.jobsCancelConfirm),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final bool isScheduled = job.status == JobStatus.scheduled;
    final bool isCancellable = job.status == JobStatus.pending ||
        job.status == JobStatus.accepted ||
        job.status == JobStatus.scheduled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isScheduled) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectionDialog(context, l10n),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.urgency,
                        side: const BorderSide(color: AppColors.urgency),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        l10n.jobsRejectAction,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<JobsBloc>()
                            .add(UpdateJobStatus(job.id, 'AGREED'));
                        context
                            .read<NavigationBloc>()
                            .add(const TabChanged(1));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        l10n.jobsConfirmAction,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            // Chat Button (Primary)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  final professional = Professional(
                    id: job.professionalId,
                    name: job.professionalName,
                    imageUrl: job.professionalImageUrl,
                    specialty: job.professionalSpecialty,
                    rating: job.rating,
                    pricePerHour: job.pricePerHour,
                    distance: 0.0,
                    description: job.workDescription ?? '',
                    latitude: 0.0,
                    longitude: 0.0,
                    isVerified: true,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        professional: professional,
                        jobId: job.id,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                label: Text(l10n.jobsGoToChat),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            if (isCancellable && !isScheduled) ...[
              const SizedBox(height: 10),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context, l10n),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.urgency,
                    side: BorderSide(color: AppColors.urgency.withValues(alpha: 0.7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.jobsCancel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (job.hasBeenReviewed) {
      final rating = job.givenRating ?? 5;
      final bool hasComment = job.reviewComment != null &&
          job.reviewComment!.trim().isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 22),
                const SizedBox(width: 8),
                Text(
                  l10n.jobsYourRating,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (hasComment) ...[
              const SizedBox(height: 10),
              Text(
                '"${job.reviewComment!.trim()}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final jobIdInt = int.tryParse(job.id) ?? 0;
          if (jobIdInt != 0) {
            showDialog(
              context: context,
              builder: (context) => RatingDialog(
                jobId: jobIdInt,
                professionalName: job.professionalName,
              ),
            );
          }
        },
        icon: const Icon(Icons.star_rounded, color: Colors.amber),
        label: Text(
          l10n.jobsRateProfessional,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildClaimSection(BuildContext context, ThemeData theme) {
    if (job.hasClaim) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_rounded, color: AppColors.error, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Reclamo en proceso",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Estado: ${job.claimStatus ?? 'Pendiente'}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tu reclamo está siendo revisado por nuestro equipo de soporte.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          final jobIdInt = int.tryParse(job.id) ?? 0;
          if (jobIdInt != 0) {
            showDialog(
              context: context,
              builder: (context) => CreateJobClaimDialog(
                jobId: jobIdInt,
                professionalName: job.professionalName,
              ),
            );
          }
        },
        icon: const Icon(Icons.report_problem_rounded, color: AppColors.error),
        label: const Text(
          "Iniciar Reclamo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedDetailsSection(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Detalles del Trabajo Finalizado',
          icon: Icons.check_circle_outline,
          theme: theme,
        ),
        const SizedBox(height: 10),
        _buildContentCard(
          theme: theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (job.finalPrice != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Valor Final:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      formatCurrency(job.finalPrice!),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (job.tradesmanComments != null && job.tradesmanComments!.isNotEmpty) ...[
                Text('Comentarios del Profesional:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(job.tradesmanComments!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
              ],
              if (job.finishedPhotosUrls != null && job.finishedPhotosUrls!.isNotEmpty) ...[
                Text('Fotos del Trabajo:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: job.finishedPhotosUrls!.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          job.finishedPhotosUrls![index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
