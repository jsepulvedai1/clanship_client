import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clanship_cliente/core/config/env_config.dart';

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

    final WebSocketLink websocketLink = WebSocketLink(
      EnvConfig.instance.websocketUrl,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: null,
        queryAndMutationTimeout: Duration(seconds: 30),
        initialPayload: () async {
          final token = await _storage.read(key: 'jwt_token');
          return {'Authorization': token != null ? 'JWT $token' : ''};
        },
      ),
    );

    final Link link = Link.split(
      (request) => request.isSubscription,
      websocketLink,
      authLink.concat(httpLink),
    );

    client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );

    // Public client: bare HTTP, no auth header, no WebSocket.
    publicClient = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    );
  }
}
