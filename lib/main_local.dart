import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/core/config/app_startup.dart';
import 'package:clanship_cliente/main.dart';

void main() async {
  await AppStartup.init();

  // For Android emulator use 10.0.2.2 to access the host loopback,
  // for iOS simulator/web/other use 127.0.0.1.
  final host = !kIsWeb && Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';

  // Instantiate Local Environment
  EnvConfig.instantiate(
    environment: Environment.local,
    baseUrl: 'http://$host:8000/graphql/',
    websocketUrl: 'ws://$host:8000/graphql/',
  );

  runApp(const ClanshipApp());
}
