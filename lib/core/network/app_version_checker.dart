import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';

class AppVersionChecker {
  static Future<bool> checkVersion({
    required BuildContext context,
    required String appType,
    required String currentVersion,
    required String baseUrl,
  }) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      String cleanBaseUrl = baseUrl.replaceAll('/graphql/', '').replaceAll('/graphql', '');
      if (cleanBaseUrl.endsWith('/')) {
        cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
      }

      final uri = Uri.parse(
        '$cleanBaseUrl/api/v1/app-version/?app_type=$appType&platform=$platform&version=$currentVersion',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool updateRequired = data['update_required'] ?? false;
        final String storeUrl = data['store_url'] ?? '';
        final String title = data['title'] ?? '';
        final String message = data['message'] ?? '';

        if (updateRequired && context.mounted) {
          _showBlockingUpdateDialog(
            context: context,
            title: title,
            message: message,
            storeUrl: storeUrl,
          );
          return true; // Bloqueado
        }
      }
    } catch (_) {
      // Si el servidor o la red no responden, permite continuar sin bloquear
    }
    return false;
  }

  static void _showBlockingUpdateDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String storeUrl,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final displayTitle = title.isNotEmpty ? title : l10n.versionUpdateTitle;
    final displayMessage = message.isNotEmpty ? message : l10n.versionUpdateMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.system_update_rounded, color: Color(0xFF0D2B45), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2B45),
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              displayMessage,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2E3135)),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2B45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (storeUrl.isNotEmpty) {
                      final uri = Uri.parse(storeUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  child: Text(
                    l10n.versionUpdateBtn,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
