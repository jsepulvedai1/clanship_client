import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/specialty_ui_helper.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.jobsRequestsTitle, 
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state is JobsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JobsLoaded) {
            if (state.jobs.isEmpty) {
              return _buildEmptyState(context, l10n);
            }
            return _buildJobsList(context, state.jobs, l10n);
          } else if (state is JobsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            l10n.jobsEmptyTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.jobsEmptySubtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(BuildContext context, List<JobMatch> jobs, AppLocalizations l10n) {
    return ListView.separated(
      key: UniqueKey(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: jobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _buildJobCard(context, job, l10n);
      },
    );
  }

  Widget _buildJobCard(BuildContext context, JobMatch job, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final icon = SpecialtyUIHelper.getIcon(job.professionalSpecialty);
    final color = SpecialtyUIHelper.getColor(job.professionalSpecialty);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailPage(job: job),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Specialty Icon Box
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 16),
            // Info
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
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildStatusInfo(job, l10n, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          size: 16,
          color: index < rating.floor() ? const Color(0xFFFFD700) : Colors.grey[300],
        );
      }),
    );
  }

  Widget _buildStatusInfo(JobMatch job, AppLocalizations l10n, ThemeData theme) {
    if (job.status == JobStatus.completed) {
      final dateStr = DateFormat('dd/MM/yyyy').format(job.timestamp);
      return Text(
        '${l10n.jobsStatusCompleted} $dateStr',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      );
    }
    
    final arrival = job.estimatedArrival ?? '00:00 Hrs.';
    return Text(
      '${l10n.jobsInProcess}: ${l10n.jobsArrivalInfo(arrival)}',
      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.bold),
    );
  }
}
