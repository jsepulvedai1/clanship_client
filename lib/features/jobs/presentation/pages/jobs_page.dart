import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/jobs/domain/entities/job_match.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/create_public_job_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/my_public_requests_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/job_status_info_sheet.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/job_timeline_card.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/rating_dialog.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum JobFilterCategory {
  all, // Todas
  publicRequests, // Solicitudes Abiertas
}

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  JobFilterCategory _selectedCategory = JobFilterCategory.all;
  JobStatus? _specificStatusFilter; // null means all
  final Set<String> _promptedJobRatingIds = {};
  int _publicRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPublicRequestsCount();
  }

  Future<void> _fetchPublicRequestsCount() async {
    try {
      final repo = getIt<JobRepository>();
      final list = await repo.getMyPublicJobRequests();
      if (mounted) {
        setState(() {
          _publicRequestsCount = list.length;
        });
      }
    } catch (_) {}
  }

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

            // Header Section: "Gestión y Seguimiento", "Mis Solicitudes" + Help Icon
            _buildHeader(theme),
            const SizedBox(height: 18),

            // 2 Primary Tabs (TODAS y ABIERTAS) + Status Filter Chips
            BlocBuilder<JobsBloc, JobsState>(
              builder: (context, state) {
                final allJobs = state is JobsLoaded ? state.jobs : <JobMatch>[];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrimaryFilterPills(theme, allJobs),
                    if (_selectedCategory == JobFilterCategory.all) ...[
                      const SizedBox(height: 12),
                      _buildSpecificStatusChips(theme, allJobs),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Content List / View
            Expanded(
              child: BlocConsumer<JobsBloc, JobsState>(
                listener: (context, state) {
                  if (state is JobsLoaded) {
                    _checkPendingRatings(state.jobs);
                  }
                },
                builder: (context, state) {
                  if (_selectedCategory == JobFilterCategory.publicRequests) {
                    return const MyPublicRequestsWidget();
                  }

                  if (state is JobsLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is JobsLoaded) {
                    final filteredJobs = _filterAndSortJobs(state.jobs);

                    if (filteredJobs.isEmpty) {
                      return _buildEmptyState(context, l10n, theme);
                    }

                    return _buildTimelineList(context, filteredJobs);
                  } else if (state is JobsError) {
                    return _buildErrorState(context, state.message, theme);
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
        elevation: 4,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePublicJobPage()),
          );
          if (res == true && mounted) {
            _fetchPublicRequestsCount();
            setState(() => _selectedCategory = JobFilterCategory.publicRequests);
          }
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'NUEVA SOLICITUD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Mis Solicitudes',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: 26,
              ),
            ),
          ),
          // Help / Info Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => JobStatusInfoSheet.show(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryFilterPills(ThemeData theme, List<JobMatch> allJobs) {
    final allCount = allJobs.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildPillButton(
              title: allCount > 0 ? 'TODAS ($allCount)' : 'TODAS',
              icon: Icons.list_alt_rounded,
              isSelected: _selectedCategory == JobFilterCategory.all,
              activeBgColor: AppColors.primary,
              activeTextColor: Colors.white,
              onTap: () {
                setState(() {
                  _selectedCategory = JobFilterCategory.all;
                  _specificStatusFilter = null;
                });
              },
              theme: theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPillButton(
              title: _publicRequestsCount > 0
                  ? 'ABIERTAS ($_publicRequestsCount)'
                  : 'ABIERTAS',
              icon: Icons.campaign_rounded,
              isSelected: _selectedCategory == JobFilterCategory.publicRequests,
              activeBgColor: const Color(0xFFE86A38),
              activeTextColor: Colors.white,
              onTap: () {
                setState(() {
                  _selectedCategory = JobFilterCategory.publicRequests;
                  _specificStatusFilter = null;
                });
              },
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String title,
    IconData? icon,
    required bool isSelected,
    required Color activeBgColor,
    required Color activeTextColor,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? activeBgColor
              : isDark
                  ? theme.colorScheme.surface
                  : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? activeBgColor
                : isDark
                    ? Colors.white12
                    : theme.dividerColor.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBgColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 17,
                color: isSelected
                    ? activeTextColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected
                    ? activeTextColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12.5,
                  letterSpacing: 0.4,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificStatusChips(ThemeData theme, List<JobMatch> allJobs) {
    final pendingCount =
        allJobs.where((j) => j.status == JobStatus.pending).length;
    final scheduledCount =
        allJobs.where((j) => j.status == JobStatus.scheduled).length;
    final acceptedCount =
        allJobs.where((j) => j.status == JobStatus.accepted).length;
    final completedCount =
        allJobs.where((j) => j.status == JobStatus.completed).length;
    final rejectedCount =
        allJobs.where((j) => j.status == JobStatus.rejected).length;

    final availableStatuses = [
      null,
      JobStatus.pending,
      JobStatus.scheduled,
      JobStatus.accepted,
      JobStatus.completed,
      JobStatus.rejected,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: availableStatuses.map((status) {
          final isSelected = _specificStatusFilter == status;
          final count = status == null
              ? allJobs.length
              : (status == JobStatus.pending
                  ? pendingCount
                  : status == JobStatus.scheduled
                      ? scheduledCount
                      : status == JobStatus.accepted
                          ? acceptedCount
                          : status == JobStatus.completed
                              ? completedCount
                              : rejectedCount);

          final label = _getStatusChipLabel(status, count);
          final chipColor = _getStatusChipColor(status);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _specificStatusFilter = status);
              },
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
              selectedColor: chipColor,
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? chipColor
                      : theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getStatusChipLabel(JobStatus? status, int count) {
    final countStr = count > 0 ? ' ($count)' : '';
    if (status == null) return 'Todos$countStr';
    switch (status) {
      case JobStatus.pending:
        return 'Cotización$countStr';
      case JobStatus.scheduled:
        return 'En camino$countStr';
      case JobStatus.accepted:
        return 'En proceso$countStr';
      case JobStatus.completed:
        return 'Finalizados$countStr';
      case JobStatus.rejected:
        return 'Rechazados$countStr';
    }
  }

  Color _getStatusChipColor(JobStatus? status) {
    if (status == null) return AppColors.primary;
    switch (status) {
      case JobStatus.pending:
        return AppColors.primary;
      case JobStatus.scheduled:
        return const Color(0xFFE86A38);
      case JobStatus.accepted:
        return const Color(0xFF0D2B45);
      case JobStatus.completed:
        return const Color(0xFF16A34A);
      case JobStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  List<JobMatch> _filterAndSortJobs(List<JobMatch> jobs) {
    var filtered = jobs;

    // Filter by specific status if selected
    if (_specificStatusFilter != null) {
      filtered = filtered.where((j) => j.status == _specificStatusFilter).toList();
    } else {
      filtered = List<JobMatch>.from(filtered);
    }

    // Sort strictly from newest to oldest
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  Widget _buildTimelineList(BuildContext context, List<JobMatch> jobs) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        _fetchPublicRequestsCount();
        context.read<JobsBloc>().add(LoadJobs());
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return JobTimelineCard(
            job: job,
            isFirst: index == 0,
            isLast: index == jobs.length - 1,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailPage(job: job),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        _fetchPublicRequestsCount();
        context.read<JobsBloc>().add(LoadJobs());
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay solicitudes aquí',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _specificStatusFilter != null
                      ? 'No tienes solicitudes con el estado seleccionado.'
                      : 'Tus nuevas solicitudes aparecerán en esta lista.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              'Ocurrió un error',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<JobsBloc>().add(LoadJobs()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkPendingRatings(List<JobMatch> jobs) {
    for (final job in jobs) {
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
}
