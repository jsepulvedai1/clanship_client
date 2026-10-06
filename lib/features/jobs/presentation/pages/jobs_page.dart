import 'dart:async';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/network/jobs_websocket_service.dart';
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
  int _publicRequestsRefreshCounter = 0;
  StreamSubscription? _socketSub;

  @override
  void initState() {
    super.initState();
    final navBloc = getIt<NavigationBloc>();
    if (navBloc.targetJobTab == 'publicRequests') {
      navBloc.targetJobTab = null;
      _selectedCategory = JobFilterCategory.publicRequests;
    }
    _fetchPublicRequestsCount();

    final socketService = getIt<JobsWebSocketService>();
    _socketSub = socketService.stream.listen((data) {
      if (mounted) {
        _fetchPublicRequestsCount();
        if (_selectedCategory == JobFilterCategory.publicRequests) {
          setState(() {
            _publicRequestsRefreshCounter++;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchPublicRequestsCount() async {
    try {
      final repo = getIt<JobRepository>();
      final list = await repo.getMyPublicJobRequests();
      if (mounted) {
        final openCount = list
            .where((r) => (r['status']?.toString() ?? 'OPEN') == 'OPEN')
            .length;
        setState(() {
          _publicRequestsCount = openCount;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<NavigationBloc, int>(
      listener: (context, currentIndex) {
        if (currentIndex == 1) {
          final navBloc = context.read<NavigationBloc>();
          if (navBloc.targetJobTab == 'publicRequests') {
            navBloc.targetJobTab = null;
            setState(() {
              _selectedCategory = JobFilterCategory.publicRequests;
              _publicRequestsRefreshCounter++;
            });
            _fetchPublicRequestsCount();
          }
        }
      },
      child: Scaffold(
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
                  final allJobs = state is JobsLoaded
                      ? state.jobs
                      : <JobMatch>[];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildPrimaryFilterPills(theme, allJobs)],
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
                      return MyPublicRequestsWidget(
                        key: ValueKey(
                          'public_requests_$_publicRequestsRefreshCounter',
                        ),
                        onRequestsChanged: () {
                          _fetchPublicRequestsCount();
                        },
                      );
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
              'Mis Requerimientos',
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
            child: _buildTabButton(
              title: 'TRABAJOS',
              count: allCount,
              isSelected: _selectedCategory == JobFilterCategory.all,
              onTap: () {
                setState(() {
                  _selectedCategory = JobFilterCategory.all;
                  _specificStatusFilter = null;
                });
              },
              theme: theme,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTabButton(
              title: 'COTIZACIONES',
              count: _publicRequestsCount,
              isSelected: _selectedCategory == JobFilterCategory.publicRequests,
              onTap: () {
                setState(() {
                  _selectedCategory = JobFilterCategory.publicRequests;
                  _specificStatusFilter = null;
                  _publicRequestsRefreshCounter++;
                });
                _fetchPublicRequestsCount();
              },
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final primaryColor = AppColors.primary;
    final textColor = isSelected
        ? primaryColor
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count >= 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : theme.dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<JobMatch> _filterAndSortJobs(List<JobMatch> jobs) {
    var filtered = jobs;

    // Filter by specific status if selected
    if (_specificStatusFilter != null) {
      filtered = filtered
          .where((j) => j.status == _specificStatusFilter)
          .toList();
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

  Widget _buildErrorState(
    BuildContext context,
    String message,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            Text(
              'Ocurrió un error',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
