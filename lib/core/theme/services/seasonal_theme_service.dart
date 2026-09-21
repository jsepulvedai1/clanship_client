import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clanship_cliente/core/theme/models/seasonal_campaign_model.dart';

class SeasonalThemeService {
  static const String _cacheKey = 'clanship_seasonal_campaign_cache';

  /// Obtiene la campaña almacenada en caché local (Offline-first, 0ms de latencia).
  Future<SeasonalCampaignModel?> getCachedCampaign() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> jsonMap = json.decode(raw);
        return SeasonalCampaignModel.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint('Error leyendo caché de SeasonalCampaign: $e');
    }
    return null;
  }

  /// Consulta el endpoint remoto de campañas de temporada y actualiza la caché local.
  Future<SeasonalCampaignModel?> fetchActiveCampaign({
    required String baseUrl,
    String appType = 'CLIENT',
  }) async {
    try {
      String cleanBaseUrl = baseUrl.replaceAll('/graphql/', '').replaceAll('/graphql', '');
      if (cleanBaseUrl.endsWith('/')) {
        cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
      }

      final uri = Uri.parse('$cleanBaseUrl/api/v1/seasonal-config/?app_type=$appType');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool hasActive = data['has_active_campaign'] == true;
        final prefs = await SharedPreferences.getInstance();

        if (hasActive && data['campaign'] != null) {
          final campaignJson = data['campaign'] as Map<String, dynamic>;
          final campaign = SeasonalCampaignModel.fromJson(campaignJson);
          await prefs.setString(_cacheKey, json.encode(campaign.toJson()));
          return campaign;
        } else {
          // No hay campaña activa: limpiar caché para restaurar apariencia nativa
          await prefs.remove(_cacheKey);
          return null;
        }
      }
    } catch (e) {
      debugPrint('Error al consultar SeasonalCampaign remota: $e');
    }

    // Fallback a caché local en caso de error de red o timeout
    return await getCachedCampaign();
  }
}
