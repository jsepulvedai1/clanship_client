import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class JobsWebSocketService {
  final storage = const FlutterSecureStorage();
  WebSocket? _socket;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnecting = false;
  Timer? _reconnectTimer;

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void connect() async {
    if (_socket != null || _isConnecting) return;
    _isConnecting = true;

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        _isConnecting = false;
        return;
      }

      // Convert from ws://.../graphql/ to ws://.../ws/jobs/
      final baseWsUrl = EnvConfig.instance.websocketUrl.replaceAll('/graphql/', '/ws/jobs/');
      final wsUrl = '$baseWsUrl?token=$token';

      debugPrint('Connecting to Jobs WebSocket: $wsUrl');
      _socket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 10));

      _socket!.listen(
        (data) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(data.toString());
            _controller.add(jsonData);
          } catch (e) {
            debugPrint('Error decoding jobs socket message: $e');
          }
        },
        onError: (err) {
          debugPrint('Jobs WebSocket error: $err');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('Jobs WebSocket connection closed');
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint('Failed to connect to Jobs WebSocket: $e');
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _scheduleReconnect() {
    _socket = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      debugPrint('Reconnecting to Jobs WebSocket...');
      connect();
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
    debugPrint('Disconnected from Jobs WebSocket');
  }
}
