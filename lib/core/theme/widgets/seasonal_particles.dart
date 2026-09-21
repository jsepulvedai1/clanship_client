import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_state.dart';

class SeasonalParticlesOverlay extends StatefulWidget {
  final double height;
  const SeasonalParticlesOverlay({super.key, this.height = 140});

  @override
  State<SeasonalParticlesOverlay> createState() => _SeasonalParticlesOverlayState();
}

class _SeasonalParticlesOverlayState extends State<SeasonalParticlesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generar 20 partículas discretas y livianas
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.15 + _random.nextDouble() * 0.35,
          size: 3.0 + _random.nextDouble() * 4.0,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 2,
          colorIndex: _random.nextInt(4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeasonalThemeBloc, SeasonalThemeState>(
      builder: (context, state) {
        if (!state.hasActiveCampaign) {
          return const SizedBox.shrink();
        }

        final effect = state.campaign?.visuals.particleEffect;
        if (effect == null || effect == 'NONE') {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                    effect: effect,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double size;
  double rotation;
  double rotationSpeed;
  int colorIndex;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.colorIndex,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final String effect;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.effect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    final confettiColors = [
      const Color(0xFFD52B1E).withValues(alpha: 0.8), // Rojo
      const Color(0xFF0D2B45).withValues(alpha: 0.8), // Azul
      Colors.white.withValues(alpha: 0.85),            // Blanco
      const Color(0xFFF28C28).withValues(alpha: 0.8), // Dorado/Naranja
    ];

    final snowColors = [
      Colors.white.withValues(alpha: 0.8),
      Colors.white.withValues(alpha: 0.6),
      Colors.white.withValues(alpha: 0.4),
      const Color(0xFFE2E8F0).withValues(alpha: 0.5),
    ];

    for (final p in particles) {
      final currentY = (p.y + progress * p.speed) % 1.0;
      final posX = p.x * size.width;
      final posY = currentY * size.height;

      if (effect == 'SNOW') {
        paint.color = snowColors[p.colorIndex % snowColors.length];
        canvas.drawCircle(Offset(posX, posY), p.size * 0.7, paint);
      } else if (effect == 'CONFETTI') {
        paint.color = confettiColors[p.colorIndex % confettiColors.length];
        canvas.save();
        canvas.translate(posX, posY);
        canvas.rotate(p.rotation + progress * p.rotationSpeed * math.pi * 2);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size * 1.6,
            height: p.size * 0.9,
          ),
          paint,
        );
        canvas.restore();
      } else {
        // STARS u otros
        paint.color = Colors.amber.withValues(alpha: 0.7);
        canvas.drawCircle(Offset(posX, posY), p.size * 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
