import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/specialty_ui_helper.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobDetailPage extends StatelessWidget {
  final JobMatch job;

  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final icon = SpecialtyUIHelper.getIcon(job.professionalSpecialty);
    final color = SpecialtyUIHelper.getColor(job.professionalSpecialty);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, icon, color, l10n),
              const SizedBox(height: 32),
              Text(
                l10n.jobsDetailTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                job.workDescription ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700], height: 1.5),
              ),
              const SizedBox(height: 48),
              _buildPriceSection(theme, l10n),
              const SizedBox(height: 40),
              _buildActions(context, l10n, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, IconData icon, Color color, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.white, size: 50),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.professionalName,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRatingStars(job.rating),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                job.professionalSpecialty,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusInfo(l10n, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          size: 20,
          color: index < rating.floor() ? const Color(0xFFFFD700) : Colors.grey[300],
        );
      }),
    );
  }

  Widget _buildStatusInfo(AppLocalizations l10n, ThemeData theme) {
    final arrival = job.estimatedArrival ?? '00:00 Hrs.';
    return Text(
      '${l10n.jobsInProcess}: ${l10n.jobsArrivalInfo(arrival)}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme, AppLocalizations l10n) {
    final value = job.totalValue ?? 0.0;
    final formatter = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.jobsTotalValue,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          '${formatter.format(value)} CLP',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            // Need to convert JobMatch info to Professional for ChatPage
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
                builder: (context) => ChatPage(professional: professional),
              ),
            );
          },
          child: Text(
            l10n.jobsGoToChat,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5277),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(l10n.jobsCancel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(l10n.jobsBack, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(Icons.favorite_border_rounded, size: 32, color: Colors.grey[800]),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
