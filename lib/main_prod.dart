import 'package:flutter/material.dart';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/core/config/app_startup.dart';
import 'package:clanship_cliente/main.dart';

void main() async {
  await AppStartup.init();

  // Instantiate Prod Environment
  EnvConfig.instantiate(
    environment: Environment.prod,
    baseUrl: 'https://api.clanship.cl/graphql/',
    websocketUrl: 'wss://api.clanship.cl/graphql/',
  );

  runApp(const ClanshipApp());
}
