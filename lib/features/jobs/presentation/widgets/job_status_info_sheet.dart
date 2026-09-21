import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class JobStatusInfoSheet extends StatelessWidget {
  const JobStatusInfoSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JobStatusInfoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estados de Solicitudes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Guía de seguimiento de tus trabajos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status items
          _buildStatusItem(
            label: 'COTIZACIÓN',
            description:
                'Tu solicitud fue enviada y el maestro está revisando los detalles para presupuestar.',
            badgeColor: AppColors.primary,
            bgTint: const Color(0xFFD8F3EC),
            icon: Icons.receipt_long_rounded,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            label: 'EN CAMINO',
            description:
                'El profesional ha programado o iniciado el traslado hacia tu domicilio.',
            badgeColor: const Color(0xFFE86A38),
            bgTint: const Color(0xFFFFE8D6),
            icon: Icons.directions_car_rounded,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            label: 'EN PROCESO',
            description:
                'El maestro aceptó el servicio y el trabajo se encuentra en ejecución activa.',
            badgeColor: const Color(0xFF0D2B45),
            bgTint: const Color(0xFFD8EAF8),
            icon: Icons.handyman_rounded,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            label: 'FINALIZADO',
            description:
                'El servicio ha concluido exitosamente y puedes calificar la atención.',
            badgeColor: const Color(0xFF16A34A),
            bgTint: const Color(0xFFDCFCE7),
            icon: Icons.check_circle_outline_rounded,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            label: 'RECHAZADO',
            description:
                'La solicitud fue declinada o cancelada por alguna de las partes.',
            badgeColor: const Color(0xFFEF4444),
            bgTint: const Color(0xFFFFE4E6),
            icon: Icons.cancel_outlined,
            theme: theme,
          ),
          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String label,
    required String description,
    required Color badgeColor,
    required Color bgTint,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : bgTint.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
