import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';

@lazySingleton
class UgcSafetyService {
  static const String _kBlockedUsersKey = 'ugc_blocked_user_ids';
  static const String _kBlockedUsersDetailsKey = 'ugc_blocked_users_details';

  final SharedPreferences _prefs;
  final ValueNotifier<List<String>> blockedUserIdsNotifier = ValueNotifier<List<String>>([]);

  UgcSafetyService(this._prefs) {
    _loadBlockedUsers();
  }

  void _loadBlockedUsers() {
    final list = _prefs.getStringList(_kBlockedUsersKey) ?? [];
    blockedUserIdsNotifier.value = list;
  }

  List<String> getBlockedUserIds() {
    return _prefs.getStringList(_kBlockedUsersKey) ?? [];
  }

  bool isUserBlocked(String userId) {
    final list = getBlockedUserIds();
    return list.contains(userId);
  }

  Map<String, Map<String, dynamic>> getBlockedUsersDetails() {
    final raw = _prefs.getString(_kBlockedUsersDetailsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
    } catch (_) {
      return {};
    }
  }

  Future<void> blockUser({
    required String userId,
    required String userName,
    String? reason,
  }) async {
    final currentList = getBlockedUserIds();
    if (!currentList.contains(userId)) {
      currentList.add(userId);
      await _prefs.setStringList(_kBlockedUsersKey, currentList);
      blockedUserIdsNotifier.value = List.from(currentList);
    }

    final details = getBlockedUsersDetails();
    details[userId] = {
      'id': userId,
      'name': userName,
      'blockedAt': DateTime.now().toIso8601String(),
      'reason': reason ?? 'Usuario abusivo / contenido inapropiado',
    };
    await _prefs.setString(_kBlockedUsersDetailsKey, jsonEncode(details));

    // Send block mutation to backend
    try {
      final client = getIt<GraphQLService>().client;
      await client.mutate(
        MutationOptions(
          document: gql(r'''
            mutation BlockUser($blockedId: Int!) {
              blockUser(blockedId: $blockedId) { success }
            }
          '''),
          variables: {'blockedId': int.tryParse(userId) ?? 0},
        ),
      );
    } catch (e) {
      debugPrint('Error sending block request to backend: $e');
    }

    // Also trigger report for developer moderation within 24h
    await reportContent(
      targetId: userId,
      targetName: userName,
      reason: reason ?? 'Usuario bloqueado por conducta abusiva o contenido inapropiado',
      details: 'El usuario bloqueó a $userName. Acción automática: contenido oculto, pendiente de expulsión por moderación (24h).',
      targetType: 'USER_BLOCK',
    );
  }

  Future<void> unblockUser(String userId) async {
    final currentList = getBlockedUserIds();
    currentList.remove(userId);
    await _prefs.setStringList(_kBlockedUsersKey, currentList);
    blockedUserIdsNotifier.value = List.from(currentList);

    final details = getBlockedUsersDetails();
    details.remove(userId);
    await _prefs.setString(_kBlockedUsersDetailsKey, jsonEncode(details));
  }

  Future<void> reportContent({
    required String targetId,
    required String targetName,
    required String reason,
    String? details,
    String targetType = 'CONTENT',
  }) async {
    // Send report mutation to backend
    try {
      final client = getIt<GraphQLService>().client;
      await client.mutate(
        MutationOptions(
          document: gql(r'''
            mutation ReportUser($reportedId: Int!, $reason: String!) {
              reportUser(reportedId: $reportedId, reason: $reason) { success }
            }
          '''),
          variables: {
            'reportedId': int.tryParse(targetId) ?? 0,
            'reason': '$targetType: $reason - $details'
          },
        ),
      );
    } catch (e) {
      debugPrint('Error sending report request to backend: $e');
    }

    // Save report locally to history
    final reportsKey = 'ugc_moderation_reports_history';
    final existingReports = _prefs.getStringList(reportsKey) ?? [];
    final reportEntry = jsonEncode({
      'targetId': targetId,
      'targetName': targetName,
      'reason': reason,
      'details': details ?? '',
      'targetType': targetType,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'PENDING_REVIEW_24H',
    });
    existingReports.add(reportEntry);
    await _prefs.setStringList(reportsKey, existingReports);
  }
}
