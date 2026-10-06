import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/network/local_notification_service.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_state.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<LocalNotificationItem> _localNotifications = [];
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadLocalNotifications();
    _notificationSubscription =
        LocalNotificationService.onNotificationAdded.listen((_) {
      _loadLocalNotifications();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalNotifications() async {
    final list = await LocalNotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _localNotifications = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await LocalNotificationService.clearAll();
              await _loadLocalNotifications();
            },
            child: Text(
              'Limpiar todo',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _localNotifications.isEmpty
          ? const Center(
              child: Text(
                'No tienes nuevas notificaciones',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _localNotifications.length,
              itemBuilder: (context, index) {
                final notif = _localNotifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () async {
                      // Marcar como leída / borrarla
                      await LocalNotificationService.deleteNotification(notif.id);

                      final event = notif.data?['event'];
                      if (event == 'chat_message') {
                        final jobIdStr = notif.data?['job_id']?.toString();
                        if (jobIdStr != null && jobIdStr.isNotEmpty) {
                          if (!context.mounted) return;
                          final jobsState = context.read<JobsBloc>().state;
                          if (jobsState is JobsLoaded) {
                            final job = jobsState.jobs.where((j) => j.id == jobIdStr).firstOrNull;
                            if (job != null) {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    professional: Professional(
                                      id: job.professionalId,
                                      name: job.professionalName,
                                      specialty: job.professionalSpecialty,
                                      rating: job.rating,
                                      distance: 0.0,
                                      latitude: 0.0,
                                      longitude: 0.0,
                                      imageUrl: job.professionalImageUrl,
                                      pricePerHour: job.pricePerHour,
                                      description: '',
                                    ),
                                    jobId: job.id,
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                        }
                      }
                      
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      context.read<NavigationBloc>().add(
                        const TabChanged(1),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      notif.body,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      onPressed: () async {
                        await LocalNotificationService.deleteNotification(
                          notif.id,
                        );
                        await _loadLocalNotifications();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
