import 'package:flutter/material.dart';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/core/config/app_startup.dart';
import 'package:clanship_cliente/main.dart';

void main() async {
  await AppStartup.init();

  // Instantiate Dev Environment
  EnvConfig.instantiate(
    environment: Environment.dev,
    baseUrl: 'https://clanship-backend.onrender.com/graphql/',
    websocketUrl: 'wss://clanship-backend.onrender.com/graphql/',
  );

  runApp(const ClanshipApp());
}
