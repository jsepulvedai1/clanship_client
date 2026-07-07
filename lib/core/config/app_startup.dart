import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/settings/settings_repository.dart';

import 'package:clanship_cliente/core/network/firebase_notification_helper.dart';

class AppStartup {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await FirebaseNotificationHelper.initialize();

    // Initialize Hive for GraphQL Cache
    await initHiveForFlutter();

    // Initialize dependency injection (Wait for pre-resolved dependencies like SharedPreferences)
    await configureDependencies();

    // Initialize Global Settings Persistence (Hive)
    final settingsRepo = getIt<SettingsRepository>();
    await settingsRepo.init();
  }
}
