import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/specialty_ui_helper.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:intl/intl.dart';

class JobDetailPage extends StatelessWidget {
  final JobMatch job;

  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = SpecialtyUIHelper.getColor(job.professionalSpecialty);

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
        foregroundColor: theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Professional Profile Card
                  _buildProfessionalCard(theme, l10n, color),
                  const SizedBox(height: 24),

                  if (job.status == JobStatus.scheduled) ...[
                    _buildProposalCard(context, theme, color),
                    const SizedBox(height: 24),
                  ],
                  
                  // Job Description Section
                  _buildSectionTitle(l10n.jobsDetailTitle, theme),
                  const SizedBox(height: 12),
                  _buildContentCard(
                    theme: theme,
                    child: Text(
                      job.workDescription ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pricing Section
                  _buildSectionTitle(l10n.jobsTotalValue, theme),
                  const SizedBox(height: 12),
                  _buildPriceCard(theme, l10n),
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

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildContentCard({required Widget child, required ThemeData theme}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProfessionalCard(ThemeData theme, AppLocalizations l10n, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Professional Photo or Placeholder
          Hero(
            tag: 'job_prof_${job.id}',
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(job.professionalImageUrl),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: color.withOpacity(0.2), width: 2),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.professionalName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.professionalSpecialty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(l10n, theme),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
              Text(
                job.rating.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
           const SizedBox(width: 6),
           Text(
             job.estimatedArrival ?? '...',
             style: theme.textTheme.bodySmall?.copyWith(
               color: AppColors.primary,
               fontWeight: FontWeight.bold,
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(ThemeData theme, AppLocalizations l10n) {
    final value = job.totalValue ?? 0.0;
    final formatter = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );
    
    return _buildContentCard(
      theme: theme,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            '${formatter.format(value)} CLP',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard(BuildContext context, ThemeData theme, Color color) {
    final arrival = job.estimatedArrival ?? 'Visita programada';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Propuesta de Visita',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'El profesional ha programado una fecha y hora para realizar la visita:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '📅   $arrival',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final bool isScheduled = job.status == JobStatus.scheduled;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
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
                      onPressed: () {
                        context.read<JobsBloc>().add(UpdateJobStatus(job.id, 'CANCELLED'));
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5277),
                        side: const BorderSide(color: Color(0xFFFF5277)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Rechazar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<JobsBloc>().add(UpdateJobStatus(job.id, 'AGREED'));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // Chat Button (Primary)
            SizedBox(
              width: double.infinity,
              height: 56,
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
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: Text(l10n.jobsGoToChat),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            if (!isScheduled) ...[
              const SizedBox(height: 12),
              // Cancel Button (Secondary/Alert)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF5277),
                    side: const BorderSide(color: Color(0xFFFF5277)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.jobsCancel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
