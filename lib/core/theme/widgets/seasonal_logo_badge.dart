import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_state.dart';

/// Widget que añade una insignia de festividad (chupalla, gorro navideño, calabaza)
/// sobre un elemento gráfico (como el avatar o el logo de Clanship) si hay una campaña activa.
class SeasonalLogoBadge extends StatelessWidget {
  final Widget child;
  final double badgeSize;
  final Alignment badgeAlignment;
  final Offset offset;

  const SeasonalLogoBadge({
    super.key,
    required this.child,
    this.badgeSize = 29,
    this.badgeAlignment = Alignment.topRight,
    this.offset = const Offset(7, -7),
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeasonalThemeBloc, SeasonalThemeState>(
      builder: (context, state) {
        if (!state.hasActiveCampaign) {
          return child;
        }

        final visuals = state.campaign?.visuals;
        final seasonType = state.campaign?.seasonType;
        final badgeUrl = visuals?.logoBadgeUrl;

        Widget? badgeWidget;

        if (badgeUrl != null && badgeUrl.isNotEmpty) {
          badgeWidget = CachedNetworkImage(
            imageUrl: badgeUrl,
            width: badgeSize,
            height: badgeSize,
            fit: BoxFit.contain,
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) => _buildFallbackEmoji(seasonType) ?? const SizedBox.shrink(),
          );
        } else {
          badgeWidget = _buildFallbackEmoji(seasonType);
        }

        if (badgeWidget == null) {
          return child;
        }

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            child,
            Positioned(
              top: badgeAlignment.y <= 0 ? offset.dy : null,
              bottom: badgeAlignment.y > 0 ? offset.dy : null,
              left: badgeAlignment.x <= 0 ? offset.dx : null,
              right: badgeAlignment.x > 0 ? offset.dx : null,
              child: IgnorePointer(
                child: badgeWidget,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildFallbackEmoji(String? seasonType) {
    String emoji = '';
    switch (seasonType) {
      case 'FIESTAS_PATRIAS':
        emoji = '🇨🇱';
        break;
      case 'HALLOWEEN':
        emoji = '🎃';
        break;
      case 'NAVIDAD':
        emoji = '🎅';
        break;
      case 'CYBER':
        emoji = '⚡';
        break;
      case 'VERANO':
        emoji = '☀️';
        break;
      default:
        return null;
    }

    return Text(
      emoji,
      style: TextStyle(fontSize: badgeSize * 0.85),
    );
  }
}
