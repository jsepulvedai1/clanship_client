import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';

@lazySingleton
class SpecialtiesCacheService {
  static const String _kSpecialtiesCacheKey = 'clanship_cached_specialties_v1';
  
  List<dynamic> _cachedSpecialties = [];
  bool _isInitialized = false;
  bool _isFetchingBackground = false;

  /// Returns the currently cached specialties immediately (0ms response time).
  List<dynamic> getSpecialties() {
    return List<dynamic>.from(_cachedSpecialties);
  }

  /// Initializes cache from SharedPreferences on app startup.
  Future<void> initCache() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_kSpecialtiesCacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          _cachedSpecialties = List<dynamic>.from(decoded);
          debugPrint('SpecialtiesCacheService: Loaded ${_cachedSpecialties.length} specialties from local storage.');
        }
      }
    } catch (e) {
      debugPrint('SpecialtiesCacheService: Error loading cached specialties: $e');
    } finally {
      _isInitialized = true;
    }
  }

  /// Trigger background fetch via GraphQL and update cache if data changed.
  Future<void> preloadOrRefresh() async {
    // 1. Ensure local disk cache is loaded into memory first
    if (!_isInitialized) {
      await initCache();
    }

    // 2. Avoid duplicate concurrent fetches
    if (_isFetchingBackground) return;
    _isFetchingBackground = true;

    try {
      const String specialtiesQuery = r'''
        query GetSpecialtiesTagsAndSubTags {
          specialties {
            id
            name
            iconUrl
            color
            tags {
              id
              name
              iconUrl
              color
              subtags {
                id
                name
                color
              }
            }
          }
        }
      ''';

      final client = getIt<GraphQLService>().client;
      final result = await client.query(
        QueryOptions(
          document: gql(specialtiesQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (!result.hasException && result.data != null) {
        final List<dynamic> freshSpecialties =
            result.data?['specialties'] as List<dynamic>? ?? [];

        if (freshSpecialties.isNotEmpty) {
          _cachedSpecialties = freshSpecialties;
          // Persist to SharedPreferences in background
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_kSpecialtiesCacheKey, jsonEncode(freshSpecialties));
          debugPrint('SpecialtiesCacheService: Background refresh successful. ${freshSpecialties.length} specialties updated.');
        }
      }
    } catch (e) {
      debugPrint('SpecialtiesCacheService: Background refresh error (offline or network error): $e');
    } finally {
      _isFetchingBackground = false;
    }
  }
}
