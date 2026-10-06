import 'dart:async';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/jobs_websocket_service.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/core/utils/currency_formatter.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/proposal_detail_page.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';

class MyPublicRequestsPage extends StatelessWidget {
  const MyPublicRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes Abiertas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const MyPublicRequestsWidget(),
    );
  }
}

class MyPublicRequestsWidget extends StatefulWidget {
  final VoidCallback? onRequestsChanged;

  const MyPublicRequestsWidget({super.key, this.onRequestsChanged});

  @override
  State<MyPublicRequestsWidget> createState() => _MyPublicRequestsWidgetState();
}

class _MyPublicRequestsWidgetState extends State<MyPublicRequestsWidget> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    final socketService = getIt<JobsWebSocketService>();
    _socketSubscription = socketService.stream.listen((_) {
      if (mounted) _fetchRequests(showLoading: false);
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchRequests({bool showLoading = true}) async {
    if (showLoading && _requests.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final repo = getIt<JobRepository>();
      final list = await repo.getMyPublicJobRequests();
      if (mounted) {
        setState(() {
          _requests = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptProposal(int proposalId, String profName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aceptar Cotización'),
        content: Text(
          '¿Deseas aceptar la propuesta del profesional $profName? Esto creará el trabajo y abrirá la sala de chat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Aceptar y Contratar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final repo = getIt<JobRepository>();
      final ok = await repo.acceptJobProposal(proposalId);
      if (mounted && ok) {
        context.read<NavigationBloc>().add(const TabChanged(1));
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Propuesta aceptada! El trabajo ha sido agendado y redirigido a Seguimiento.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _fetchRequests();
        widget.onRequestsChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _cancelRequest(int requestId) async {
    try {
      final repo = getIt<JobRepository>();
      final ok = await repo.cancelPublicJobRequest(requestId);
      if (mounted && ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Solicitud cancelada.')));
        _fetchRequests();
        widget.onRequestsChanged?.call();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final openRequests = _requests
        .where((r) => (r['status']?.toString() ?? 'OPEN') == 'OPEN')
        .toList();

    if (openRequests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: openRequests.length,
        itemBuilder: (context, index) {
          final req = openRequests[index];
          final List proposals = req['proposals'] ?? [];
          final isUrgent = req['isUrgent'] == true;
          final status = req['status']?.toString() ?? 'OPEN';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? Colors.red.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isUrgent
                              ? '🚨 Urgente'
                              : (req['specialtyName'] ?? 'General'),
                          style: TextStyle(
                            color: isUrgent ? Colors.red : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        status == 'OPEN'
                            ? '🟢 Abierta'
                            : (status == 'ASSIGNED'
                                  ? '✅ Asignada'
                                  : '⚪ Cerrada'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    req['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    req['description'] ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          req['address'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (req['budget'] != null) ...[
                        Text(
                          'Presupuesto: ${formatCurrency(req['budget'])}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Cotizaciones Recibidas (${proposals.length}/5)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status == 'OPEN')
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _cancelRequest(
                            int.tryParse(req['id'].toString()) ?? 0,
                          ),
                          child: const Text(
                            'Cancelar Solicitud',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  if (proposals.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Aún no has recibido cotizaciones. Los maestros cercanos te las enviarán pronto.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: proposals.map((prop) {
                        final pId = int.tryParse(prop['id'].toString()) ?? 0;
                        final profName = prop['professionalName'] ?? 'Profesional';
                        final rating = prop['professionalRating']?.toString() ?? '0.0';
                        final price = prop['estimatedPrice'] ?? '0';
                        final propStatus = prop['status']?.toString();
                        final isAccepted = propStatus == 'ACCEPTED';
                        
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProposalDetailPage(
                                  request: req,
                                  proposal: prop,
                                  onAccept: _acceptProposal,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isAccepted ? Colors.green.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isAccepted ? Colors.green.shade200 : Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: prop['professionalAvatarUrl'] != null 
                                      ? NetworkImage(prop['professionalAvatarUrl']) 
                                      : null,
                                  backgroundColor: Colors.grey.shade200,
                                  child: prop['professionalAvatarUrl'] == null
                                      ? const Icon(Icons.person, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                          Text(' $rating', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatCurrency(price),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isAccepted ? Colors.green.shade700 : Colors.green),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(isAccepted ? '✅ Aceptada' : 'Ver Detalle', style: TextStyle(fontSize: 12, color: isAccepted ? Colors.green : Colors.blue)),
                                        if (!isAccepted) const Icon(Icons.chevron_right, size: 16, color: Colors.blue),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aún no has publicado ninguna solicitud de trabajo abierta.',
            style: TextStyle(fontSize: 15, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // ElevatedButton.icon(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppColors.primary,
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //   ),
          //   onPressed: () async {
          //     final res = await Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const CreatePublicJobPage()),
          //     );
          //     if (res == true) _fetchRequests();
          //   },
          //   icon: const Icon(Icons.add_rounded, color: Colors.white),
          //   label: const Text('Publicar Nueva Solicitud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          // ),
        ],
      ),
    );
  }
}
