import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/specialty_ui_helper.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  int _selectedTabIndex = 0; // 0: En proceso, 1: Finalizadas

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
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildTabSelector(l10n, theme),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<JobsBloc, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is JobsLoaded) {
                  final filteredJobs = state.jobs.where((job) {
                    if (_selectedTabIndex == 0) {
                      return job.status == JobStatus.pending ||
                          job.status == JobStatus.scheduled ||
                          job.status == JobStatus.accepted;
                    } else {
                      return job.status == JobStatus.completed || job.status == JobStatus.rejected;
                    }
                  }).toList();

                  if (filteredJobs.isEmpty) {
                    return _buildEmptyState(context, l10n, theme);
                  }
                  return _buildJobsList(context, filteredJobs, l10n);
                } else if (state is JobsError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(AppLocalizations l10n, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: l10n.jobsInProcess,
              isSelected: _selectedTabIndex == 0,
              onTap: () => setState(() => _selectedTabIndex = 0),
              theme: theme,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: l10n.jobsFinished,
              isSelected: _selectedTabIndex == 1,
              onTap: () => setState(() => _selectedTabIndex = 1),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onPrimary : AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<JobsBloc>().add(LoadJobs());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_outline_rounded, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  l10n.jobsEmptyTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.jobsEmptySubtitle,
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobsList(BuildContext context, List<JobMatch> jobs, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<JobsBloc>().add(LoadJobs());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.separated(
        key: ValueKey('jobs_list_$_selectedTabIndex'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: jobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _buildJobCard(context, job, l10n);
        },
      ),
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
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Specialty Icon Box
            Badge(
              isLabelVisible: job.hasUnreadMessages,
              backgroundColor: const Color(0xFFEF4444),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
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
                      _buildRatingStars(job.rating, theme),
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

  Widget _buildRatingStars(double rating, ThemeData theme) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          size: 16,
          color: index < rating.floor() ? const Color(0xFFFFD700) : theme.dividerColor,
        );
      }),
    );
  }

  Widget _buildStatusInfo(JobMatch job, AppLocalizations l10n, ThemeData theme) {
    if (job.status == JobStatus.completed) {
      final dateStr = DateFormat('dd/MM/yyyy').format(job.timestamp);
      return Text(
        '${l10n.jobsStatusCompleted} $dateStr',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
      );
    } else if (job.status == JobStatus.rejected) {
      final dateStr = DateFormat('dd/MM/yyyy').format(job.timestamp);
      return Text(
        '${l10n.jobsStatusRejected} $dateStr',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
      );
    } else if (job.status == JobStatus.scheduled) {
      return Text(
        'Visita Propuesta - Por Validar',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.orange[800],
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    final arrival = job.estimatedArrival ?? '00:00 Hrs.';
    return Text(
      '${l10n.jobsInProcess}: ${l10n.jobsArrivalInfo(arrival)}',
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.bold),
    );
  }
}
