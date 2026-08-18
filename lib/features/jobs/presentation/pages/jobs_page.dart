import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/my_public_requests_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/create_public_job_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/rating_dialog.dart';
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
  int _selectedTabIndex = 0; // 0: En proceso, 1: Finalizada, 2: Rechazada
  final Set<String> _promptedJobRatingIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GESTIÓN Y SEGUIMIENTO',
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.2,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mis Solicitudes',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3-Tab Selector
            _buildTabSelector(l10n, theme),
            const SizedBox(height: 20),

            // Content List
            Expanded(
              child: BlocConsumer<JobsBloc, JobsState>(
                listener: (context, state) {
                  if (state is JobsLoaded) {
                    for (final job in state.jobs) {
                      if (job.status == JobStatus.completed &&
                          !job.hasBeenReviewed &&
                          !_promptedJobRatingIds.contains(job.id)) {
                        _promptedJobRatingIds.add(job.id);
                        final jobIdInt = int.tryParse(job.id) ?? 0;
                        if (jobIdInt != 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (_) => RatingDialog(
                                  jobId: jobIdInt,
                                  professionalName: job.professionalName,
                                ),
                              );
                            }
                          });
                        }
                        break;
                      }
                    }
                  }
                },
                builder: (context, state) {
                  if (_selectedTabIndex == 1) {
                    return const MyPublicRequestsWidget();
                  }
                  if (state is JobsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is JobsLoaded) {
                    final filteredJobs = state.jobs.where((job) {
                      if (_selectedTabIndex == 0) {
                        return job.status == JobStatus.pending ||
                            job.status == JobStatus.scheduled ||
                            job.status == JobStatus.accepted;
                      } else if (_selectedTabIndex == 2) {
                        return job.status == JobStatus.completed;
                      } else {
                        return job.status == JobStatus.rejected;
                      }
                    }).toList();

                    if (filteredJobs.isEmpty) {
                      return _buildEmptyState(context, l10n, theme);
                    }
                    return _buildTimelineJobsList(context, filteredJobs, l10n);
                  } else if (state is JobsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePublicJobPage()),
          );
          if (res == true && mounted) {
            setState(() => _selectedTabIndex = 1);
          }
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Publicar Solicitud',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTabSelector(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTabPill(
            title: 'En proceso',
            isSelected: _selectedTabIndex == 0,
            activeColor: AppColors.primary,
            onTap: () => setState(() => _selectedTabIndex = 0),
            theme: theme,
          ),
          const SizedBox(width: 10),
          _buildTabPill(
            title: '📢 Solicitudes Abiertas',
            isSelected: _selectedTabIndex == 1,
            activeColor: Colors.deepOrange.shade600,
            onTap: () => setState(() => _selectedTabIndex = 1),
            theme: theme,
          ),
          const SizedBox(width: 10),
          _buildTabPill(
            title: 'Finalizadas',
            isSelected: _selectedTabIndex == 2,
            activeColor: Colors.green.shade600,
            onTap: () => setState(() => _selectedTabIndex = 2),
            theme: theme,
          ),
          const SizedBox(width: 10),
          _buildTabPill(
            title: 'Rechazadas',
            isSelected: _selectedTabIndex == 3,
            activeColor: const Color(0xFFFF4B6E),
            onTap: () => setState(() => _selectedTabIndex = 3),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeColor : theme.dividerColor,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? activeColor
                : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<JobsBloc>().add(LoadJobs());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.jobsEmptyTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.jobsEmptySubtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineJobsList(
    BuildContext context,
    List<JobMatch> jobs,
    AppLocalizations l10n,
  ) {
    Color accentColor = AppColors.primary;
    if (_selectedTabIndex == 1) {
      accentColor = Colors.green.shade600;
    } else if (_selectedTabIndex == 2) {
      accentColor = const Color(0xFFFF4B6E);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<JobsBloc>().add(LoadJobs());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        key: ValueKey('timeline_jobs_list_$_selectedTabIndex'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _buildTimelineItem(
            context,
            job,
            index,
            jobs.length,
            accentColor,
            l10n,
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    JobMatch job,
    int index,
    int totalCount,
    Color accentColor,
    AppLocalizations l10n,
  ) {
    final isFirst = index == 0;
    final isLast = index == totalCount - 1;

    return Stack(
      children: [
        // Vertical Line
        Positioned(
          left: 11,
          top: isFirst ? 24 : 0,
          bottom: isLast ? 24 : 0,
          child: Container(width: 2, color: accentColor.withOpacity(0.2)),
        ),
        // Content
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Timeline Connector & Dot
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
                      color: accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildJobCard(context, job, accentColor, l10n),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    JobMatch job,
    Color accentColor,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final specialtyColor = SpecialtyUIHelper.getColor(
      job.professionalSpecialty,
    );

    final dateFormatted = DateFormat('dd MMM').format(job.timestamp);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailPage(job: job)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Badge(
                  isLabelVisible: job.hasUnreadMessages,
                  backgroundColor: const Color(0xFFEF4444),
                  child: _buildAvatar(job, specialtyColor, theme),
                ),
                const SizedBox(width: 12),
                // Header Info (Name, Date, Specialty)
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
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            dateFormatted,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.professionalSpecialty.toUpperCase(),
                        style: TextStyle(
                          color: specialtyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Work Description
            Text(
              job.workDescription != null && job.workDescription!.isNotEmpty
                  ? job.workDescription!
                  : 'Sin descripción adicional',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // Rating Stars
            _buildRatingStars(job.rating, theme),

            // Rejection reason container (Only on Rechazada tab)
            if (_selectedTabIndex == 3) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4B6E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFF4B6E).withOpacity(0.25),
                  ),
                ),
                child: Text(
                  job.cancellationReason != null &&
                          job.cancellationReason!.isNotEmpty
                      ? job.cancellationReason!
                      : 'Solicitud no disponible',
                  style: const TextStyle(
                    color: Color(0xFFFF4B6E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(JobMatch job, Color specialtyColor, ThemeData theme) {
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
      backgroundColor: specialtyColor,
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating, ThemeData theme) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          size: 18,
          color: index < rating.floor()
              ? const Color(0xFFFFD700)
              : theme.dividerColor,
        );
      }),
    );
  }
}
