import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_state.dart';

/// Ubicación donde se renderiza la guirnalda
enum GarlandSlot {
  top,
  bottom,
  any,
}

/// Fila decorativa con efecto de suspensión física y balanceo de brisa:
/// - 🇨🇱 Fiestas Patrias: Banderas chilenas colgadas de una cuerda que se mecen suavemente.
/// - 🎃 Halloween: Murciélagos colgando de hilos de telaraña con balanceo pendular.
/// - 🎅 Navidad: Guirnalda de pino con luces titilantes y lazos rojos que oscilan.
/// Controlada desde Django Admin con el interruptor `show_top_garland` y `garland_position`.
class SeasonalTopGarland extends StatefulWidget {
  final double height;
  final GarlandSlot slot;

  const SeasonalTopGarland({
    super.key,
    this.height = 28,
    this.slot = GarlandSlot.any,
  });

  @override
  State<SeasonalTopGarland> createState() => _SeasonalTopGarlandState();
}

class _SeasonalTopGarlandState extends State<SeasonalTopGarland>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
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
        if (!state.hasActiveCampaign || !state.showTopGarland) {
          return const SizedBox.shrink();
        }

        // Validación de ranura / posición
        if (widget.slot == GarlandSlot.top && !state.showGarlandTop) {
          return const SizedBox.shrink();
        }
        if (widget.slot == GarlandSlot.bottom && !state.showGarlandBottom) {
          return const SizedBox.shrink();
        }

        final customUrl = state.customGarlandUrl;
        if (customUrl != null && customUrl.isNotEmpty) {
          return SizedBox(
            width: double.infinity,
            height: widget.height,
            child: CachedNetworkImage(
              imageUrl: customUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          );
        }

        final seasonType = state.campaign?.seasonType ?? 'CUSTOM';

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return IgnorePointer(
              child: SizedBox(
                width: double.infinity,
                height: widget.height,
                child: CustomPaint(
                  painter: _getPainter(seasonType, _controller.value),
                ),
              ),
            );
          },
        );
      },
    );
  }

  CustomPainter _getPainter(String seasonType, double animationValue) {
    switch (seasonType) {
      case 'FIESTAS_PATRIAS':
        return _ChileanBuntingPainter(animationValue);
      case 'HALLOWEEN':
        return _HalloweenBatsPainter(animationValue);
      case 'NAVIDAD':
        return _ChristmasGarlandPainter(animationValue);
      default:
        return _ChileanBuntingPainter(animationValue);
    }
  }
}

// ----------------------------------------------------------------------
// 🇨🇱 FIESTAS PATRIAS: Banderas chilenas colgadas con balanceo físico y cuerda combada
// ----------------------------------------------------------------------
class _ChileanBuntingPainter extends CustomPainter {
  final double progress;

  const _ChileanBuntingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final swagWidth = 80.0;
    final ropePaint = Paint()
      ..color = const Color(0xFFF1F5F9).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final ropeShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final pinPaint = Paint()..color = const Color(0xFFE2E8F0);
    final clipPaint = Paint()..color = const Color(0xFFD1D5DB);

    // 1. Cuerda física superior en arcos catenarios continuos
    final ropePath = Path()..moveTo(0, 2.5);
    final shadowRopePath = Path()..moveTo(0, 3.5);

    for (double segX = 0; segX < size.width + swagWidth; segX += swagWidth) {
      final midX = segX + swagWidth / 2;
      final endX = segX + swagWidth;
      ropePath.quadraticBezierTo(midX, 7.5, endX, 2.5);
      shadowRopePath.quadraticBezierTo(midX, 8.5, endX, 3.5);
    }
    canvas.drawPath(shadowRopePath, ropeShadowPaint);
    canvas.drawPath(ropePath, ropePaint);

    // Pines de fijación en los extremos de cada arco
    for (double pinX = 0; pinX < size.width + swagWidth; pinX += swagWidth) {
      canvas.drawCircle(Offset(pinX, 2.5), 2.0, pinPaint);
    }

    final flagSpacing = 26.0;
    final flagWidth = 16.0;
    final flagHeight = 17.0;
    final flagCount = (size.width / flagSpacing).ceil() + 1;

    final whitePaint = Paint()..color = Colors.white;
    final bluePaint = Paint()..color = const Color(0xFF002B7F); // Azul de la bandera chilena
    final redPaint = Paint()..color = const Color(0xFFD52B1E); // Rojo de la bandera chilena
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);

    for (int i = 0; i < flagCount; i++) {
      final left = i * flagSpacing + 3.0;
      if (left > size.width) break;

      final centerX = left + flagWidth / 2;

      // Calcular la altura exacta de la comba de la cuerda en la posición de esta bandera
      final u = ((centerX % swagWidth) / swagWidth).clamp(0.0, 1.0);
      // Ecuación de Bezier cuadrática: y(u) = 2.5 + 10 * u * (1 - u)
      final ropeY = 2.5 + 10.0 * u * (1.0 - u);

      // Oscilación pendular de la brisa con desfase armónico por posición
      final swingAngle = math.sin(progress * 2 * math.pi + i * 0.65) * 0.09;
      final pivotX = centerX;
      final pivotY = ropeY;

      canvas.save();
      // Rotar la bandera alrededor de su punto de sujeción a la cuerda
      canvas.translate(pivotX, pivotY);
      canvas.rotate(swingAngle);
      canvas.translate(-pivotX, -pivotY);

      // Pinzas / sujeciones de la bandera a la cuerda
      canvas.drawCircle(Offset(left + 2.5, pivotY), 1.2, clipPaint);
      canvas.drawCircle(Offset(left + flagWidth - 2.5, pivotY), 1.2, clipPaint);

      final flagTop = pivotY + 1.2;
      final flagRect = Rect.fromLTWH(left, flagTop, flagWidth, flagHeight);
      final rrect = RRect.fromRectAndRadius(flagRect, const Radius.circular(1.2));

      // Sombra colgante proyectada detrás
      canvas.drawRRect(rrect.shift(const Offset(0.5, 1.8)), shadowPaint);

      // Franja inferior roja
      canvas.save();
      canvas.clipRRect(rrect);

      canvas.drawRect(
        Rect.fromLTWH(left, flagTop + flagHeight / 2, flagWidth, flagHeight / 2),
        redPaint,
      );

      // Franja superior blanca
      canvas.drawRect(
        Rect.fromLTWH(left, flagTop, flagWidth, flagHeight / 2),
        whitePaint,
      );

      // Cantón azul patrio (cuadrante superior izquierdo)
      final cantonWidth = flagWidth * 0.46;
      final cantonHeight = flagHeight / 2;
      canvas.drawRect(
        Rect.fromLTWH(left, flagTop, cantonWidth, cantonHeight),
        bluePaint,
      );

      // Estrella solitaria chilena de 5 puntas
      _drawStar(
        canvas,
        Offset(left + cantonWidth / 2, flagTop + cantonHeight / 2),
        cantonWidth * 0.28,
        whitePaint,
      );

      // Sutil sombreado de pliegue textil por el viento
      final foldOffset = (0.3 + 0.15 * math.sin(progress * 2 * math.pi + i)).clamp(0.1, 0.9);
      final foldPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: [0.0, foldOffset * 0.8, foldOffset, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(flagRect);
      canvas.drawRect(flagRect, foldPaint);

      canvas.restore();
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final double innerRadius = radius * 0.45;
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = (i * 72 + 36 - 90) * math.pi / 180;
      final ox = center.dx + radius * math.cos(outerAngle);
      final oy = center.dy + radius * math.sin(outerAngle);
      final ix = center.dx + innerRadius * math.cos(innerAngle);
      final iy = center.dy + innerRadius * math.sin(innerAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChileanBuntingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ----------------------------------------------------------------------
// 🎃 HALLOWEEN: Murciélagos suspendidos con hilos y balanceo pendular
// ----------------------------------------------------------------------
class _HalloweenBatsPainter extends CustomPainter {
  final double progress;

  const _HalloweenBatsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final threadPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final batBodyPaint = Paint()..color = const Color(0xFF181324);
    final batEyePaint = Paint()..color = const Color(0xFFFF9800); // Ojos ámbar
    final glowEyePaint = Paint()
      ..color = const Color(0xFFFF9800).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);

    final batSpacing = 44.0;
    final batCount = (size.width / batSpacing).ceil() + 1;

    for (int i = 0; i < batCount; i++) {
      final x = i * batSpacing + 14.0;
      final threadLen = (i % 2 == 0) ? 14.0 : 19.0;

      // Balanceo pendular físico desde el punto de anclaje superior
      final batSwing = math.sin(progress * 2 * math.pi + i * 0.9) * 0.14;

      canvas.save();
      // Giro desde el anclaje superior del techo
      canvas.translate(x, 0);
      canvas.rotate(batSwing);

      // Hilo de telaraña colgante
      canvas.drawLine(Offset.zero, Offset(0, threadLen), threadPaint);

      // Murciélago colgando en el extremo inferior del hilo
      _drawHangingBat(canvas, Offset(0, threadLen), batBodyPaint, batEyePaint, glowEyePaint);

      canvas.restore();
    }
  }

  void _drawHangingBat(
    Canvas canvas,
    Offset pos,
    Paint bodyPaint,
    Paint eyePaint,
    Paint glowEyePaint,
  ) {
    final path = Path();
    const w = 13.0;
    const h = 8.0;

    // Patitas colgadas del hilo
    canvas.drawLine(pos, Offset(pos.dx - 1.5, pos.dy + 1.5), bodyPaint..strokeWidth = 1.2);
    canvas.drawLine(pos, Offset(pos.dx + 1.5, pos.dy + 1.5), bodyPaint..strokeWidth = 1.2);

    final cy = pos.dy + 2.0;

    // Silueta de murciélago con alas curvas y orejitas
    path.moveTo(pos.dx, cy + h);
    // Ala izquierda festoneada
    path.quadraticBezierTo(pos.dx - w * 0.45, cy + h * 0.8, pos.dx - w, cy + h * 0.2);
    path.quadraticBezierTo(pos.dx - w * 0.65, cy + h * 0.35, pos.dx - w * 0.35, cy + h * 0.2);
    // Cabeza y orejas
    path.lineTo(pos.dx - 2.2, cy + 0.5); // Oreja izq
    path.lineTo(pos.dx, cy + 2.5); // Coronilla
    path.lineTo(pos.dx + 2.2, cy + 0.5); // Oreja der
    // Ala derecha festoneada
    path.lineTo(pos.dx + w * 0.35, cy + h * 0.2);
    path.quadraticBezierTo(pos.dx + w * 0.65, cy + h * 0.35, pos.dx + w, cy + h * 0.2);
    path.quadraticBezierTo(pos.dx + w * 0.45, cy + h * 0.8, pos.dx, cy + h);
    path.close();

    canvas.drawPath(path, bodyPaint);

    // Ojos luminosos de murciélago
    canvas.drawCircle(Offset(pos.dx - 2.0, cy + 3.8), 1.3, glowEyePaint);
    canvas.drawCircle(Offset(pos.dx + 2.0, cy + 3.8), 1.3, glowEyePaint);
    canvas.drawCircle(Offset(pos.dx - 2.0, cy + 3.8), 0.85, eyePaint);
    canvas.drawCircle(Offset(pos.dx + 2.0, cy + 3.8), 0.85, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _HalloweenBatsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ----------------------------------------------------------------------
// 🎅 NAVIDAD: Guirnalda de festones de pino con luces y lazos balanceándose
// ----------------------------------------------------------------------
class _ChristmasGarlandPainter extends CustomPainter {
  final double progress;

  const _ChristmasGarlandPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final pineBasePaint = Paint()
      ..color = const Color(0xFF143B2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round;

    final pineNeedlePaint = Paint()
      ..color = const Color(0xFF2E8B57)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final bowPaint = Paint()..color = const Color(0xFFD32F2F);
    final goldKnotPaint = Paint()..color = const Color(0xFFFFD700);

    final bulbColors = [
      const Color(0xFFFFD700), // Dorado
      const Color(0xFFFF3B30), // Rojo
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFFFF9500), // Ámbar
    ];

    final swagWidth = 52.0;
    final swagCount = (size.width / swagWidth).ceil() + 1;

    for (int i = 0; i < swagCount; i++) {
      final startX = i * swagWidth;
      final endX = startX + swagWidth;
      final midX = (startX + endX) / 2;

      // Caída curva del festón de pino
      final swagPath = Path()
        ..moveTo(startX, 2.5)
        ..quadraticBezierTo(midX, 15.5, endX, 2.5);

      canvas.drawPath(swagPath, pineBasePaint);
      canvas.drawPath(swagPath, pineNeedlePaint);

      // Lazo rojo decorativo en el anclaje con suave balanceo de brisa
      final bowSwing = math.sin(progress * 2 * math.pi + i * 0.8) * 0.08;
      canvas.save();
      canvas.translate(startX, 3.5);
      canvas.rotate(bowSwing);

      // Lazos laterales
      final leftLoop = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-5, -4, -6, 0)
        ..quadraticBezierTo(-5, 4, 0, 0);
      final rightLoop = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(5, -4, 6, 0)
        ..quadraticBezierTo(5, 4, 0, 0);
      canvas.drawPath(leftLoop, bowPaint);
      canvas.drawPath(rightLoop, bowPaint);

      // Nudo central dorado
      canvas.drawCircle(Offset.zero, 2.0, goldKnotPaint);

      // Colas del lazo colgantes
      canvas.drawLine(Offset.zero, const Offset(-3, 8), bowPaint..strokeWidth = 1.6);
      canvas.drawLine(Offset.zero, const Offset(3, 8), bowPaint..strokeWidth = 1.6);

      canvas.restore();

      // Luces de colores titilantes con pulso de luminosidad
      final bulbX1 = startX + swagWidth * 0.32;
      final bulbX2 = startX + swagWidth * 0.68;
      final bulbColor1 = bulbColors[(i * 2) % bulbColors.length];
      final bulbColor2 = bulbColors[(i * 2 + 1) % bulbColors.length];

      final pulse1 = 0.5 + 0.5 * math.sin(progress * 2 * math.pi * 2 + i);
      final pulse2 = 0.5 + 0.5 * math.cos(progress * 2 * math.pi * 2 + i);

      _drawLightBulb(canvas, Offset(bulbX1, 10.0), bulbColor1, pulse1);
      _drawLightBulb(canvas, Offset(bulbX2, 11.2), bulbColor2, pulse2);
    }
  }

  void _drawLightBulb(Canvas canvas, Offset center, Color color, double pulse) {
    // Alambre fino del que cuelga la bombilla
    final wirePaint = Paint()
      ..color = const Color(0xFF143B2F)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(center.dx, center.dy - 3), center, wirePaint);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.28 + 0.38 * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5 + 2.5 * pulse);
    final bulbPaint = Paint()..color = color;

    canvas.drawCircle(center, 2.6 + 1.4 * pulse, glowPaint);
    canvas.drawCircle(center, 1.9, bulbPaint);
    // Destello blanco en el centro
    canvas.drawCircle(
      Offset(center.dx - 0.5, center.dy - 0.5),
      0.6,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _ChristmasGarlandPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
