import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/core/network/session_service.dart';

@lazySingleton
class GraphQLService {
  late final GraphQLClient client;

  /// Client for public endpoints that do NOT require authentication
  /// (e.g. forgot password, verify OTP, reset password).
  /// Uses plain HTTP only — no AuthLink, no WebSocket — so a WS
  /// connection failure cannot contaminate these calls.
  late final GraphQLClient publicClient;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  GraphQLService() {
    final HttpLink httpLink = HttpLink(EnvConfig.instance.baseUrl);

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null && token.isNotEmpty) {
          return 'JWT $token';
        }
        return null;
      },
    );


    final ErrorLink errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) async* {
        bool shouldRetry = false;
        bool isTokenExpired = false;
        bool isSessionInvalidated = false;

        for (final error in response.errors ?? []) {
          final message = error.message;
          if (message.contains('SESSION_INVALIDATED')) {
            isSessionInvalidated = true;
          } else if (message.contains('Signature has expired') ||
              message.contains('Error decoding signature') ||
              message.contains('Token is invalid') ||
              message.contains('TOKEN_EXPIRED')) {
            isTokenExpired = true;
          }
        }

        if (isSessionInvalidated) {
          await _storage.delete(key: 'jwt_token');
          await _storage.delete(key: 'refresh_token');
          SessionService.instance.notifySessionInvalidated(
            'Tu sesión ha sido iniciada en otro dispositivo.',
          );
          yield response;
          return;
        }

        if (isTokenExpired) {
          final refreshToken = await _storage.read(key: 'refresh_token');
          if (refreshToken != null && refreshToken.isNotEmpty) {
            final refreshedToken = await _refreshToken(refreshToken);
            if (refreshedToken != null) {
              await _storage.write(key: 'jwt_token', value: refreshedToken);
              shouldRetry = true;
            }
          }
          if (!shouldRetry) {
            await _storage.delete(key: 'jwt_token');
            await _storage.delete(key: 'refresh_token');
            SessionService.instance.notifySessionInvalidated(
              'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
            );
          }
        }

        if (shouldRetry) {
          final newToken = await _storage.read(key: 'jwt_token');
          final updatedRequest = request.updateContextEntry<HttpLinkHeaders>(
            (headers) => HttpLinkHeaders(
              headers: {
                ...headers?.headers ?? {},
                'Authorization': 'JWT $newToken',
              },
            ),
          );
          yield* forward(updatedRequest);
        } else {
          yield response;
        }
      },
    );

    final Link link = Link.from([authLink, errorLink, httpLink]);

    client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
      queryRequestTimeout: null,
    );

    // Public client: bare HTTP, no auth header, no WebSocket.
    publicClient = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
      queryRequestTimeout: null,
    );
  }

  Future<String?> _refreshToken(String refreshToken) async {
    const String refreshMutation = r'''
      mutation RefreshToken($refreshToken: String!) {
        refreshToken(refreshToken: $refreshToken) {
          token
          refreshToken
        }
      }
    ''';

    try {
      final MutationOptions options = MutationOptions(
        document: gql(refreshMutation),
        variables: {'refreshToken': refreshToken},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await publicClient.mutate(options);
      if (!result.hasException) {
        final newToken = result.data?['refreshToken']?['token'] as String?;
        final newRefreshToken = result.data?['refreshToken']?['refreshToken'] as String?;
        if (newRefreshToken != null) {
          await _storage.write(key: 'refresh_token', value: newRefreshToken);
        }
        return newToken;
      }
    } catch (e) {
      // Ignore, will return null
    }
    return null;
  }
}
