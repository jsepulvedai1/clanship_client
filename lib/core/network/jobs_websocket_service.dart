import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
  int _reconnectAttempts = 0;

  Stream<Map<String, dynamic>> get stream => _controller.stream;
  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  void connect() async {
    if (_socket != null && _socket!.readyState == WebSocket.open) return;
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        _isConnecting = false;
        return;
      }

      try {
        await _socket?.close();
      } catch (_) {}
      _socket = null;

      // Convert from ws://.../graphql/ to ws://.../ws/jobs/
      final baseWsUrl = EnvConfig.instance.websocketUrl.replaceAll('/graphql/', '/ws/jobs/');
      final wsUrl = '$baseWsUrl?token=$token';

      debugPrint('Connecting to Jobs WebSocket: $wsUrl');
      _socket = await WebSocket.connect(wsUrl);
      // Heartbeat ping cada 15 segundos para mantener viva la conexión TCP con Daphne/Caddy
      _socket!.pingInterval = const Duration(seconds: 15);
      _reconnectAttempts = 0;

      _socket!.listen(
        (data) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(data.toString());
            if (!_controller.isClosed) {
              _controller.add(jsonData);
            }
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
        cancelOnError: true,
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
    final delaySeconds = min(3 * pow(2, _reconnectAttempts).toInt(), 30);
    _reconnectAttempts++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      final token = await storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        debugPrint('Reconnecting to Jobs WebSocket (Attempt $_reconnectAttempts, Delay: ${delaySeconds}s)...');
        connect();
      }
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _socket?.close();
    _socket = null;
    _isConnecting = false;
    debugPrint('Disconnected from Jobs WebSocket');
  }

  @disposeMethod
  void dispose() {
    disconnect();
    _controller.close();
  }
}
