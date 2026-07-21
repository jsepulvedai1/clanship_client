import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:clanship_cliente/firebase_options.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:clanship_cliente/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:clanship_cliente/core/network/local_notification_service.dart';

class FirebaseNotificationHelper {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('User granted client notification permission: ${settings.authorizationStatus}');

      // Habilitar alertas/popups/sonidos cuando la app está abierta en primer plano (foreground)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground client push notification received: ${message.notification?.title} - ${message.notification?.body}');
        _handleIncomingMessage(message);
      });

      // Handle notification taps when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification opened app: ${message.messageId}');
        _handleIncomingMessage(message);
      });

      // Check if the app was opened by a notification tap from terminated state
      messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('App opened from terminated state via notification: ${message.messageId}');
          _handleIncomingMessage(message);
        }
      });

      // Handle background/terminated state messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Listen to token refresh and update backend
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        debugPrint('Client FCM Token refreshed: $token');
        _sendTokenToBackend(token);
      });
    } catch (e) {
      debugPrint('Error initializing Firebase Push Notifications in client: $e');
    }
  }

  static void _handleIncomingMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Notificación';
    final body = message.notification?.body ?? message.data['body'] ?? 'Tienes un nuevo mensaje';
    LocalNotificationService.saveNotification(title, body);

    try {
      getIt<JobsBloc>().add(LoadJobs());
    } catch (_) {}
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Background client message received: ${message.messageId}');
    final title = message.notification?.title ?? message.data['title'] ?? 'Notificación';
    final body = message.notification?.body ?? message.data['body'] ?? 'Tienes un nuevo mensaje';
    await LocalNotificationService.saveNotification(title, body);
  }

  static Future<void> uploadFcmToken() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        int retries = 0;
        // Aumentar los intentos a 8 con retraso de 1.5s para dar suficiente margen en iPhones reales
        while (apnsToken == null && retries < 8) {
          debugPrint('APNS token not set yet. Waiting 1.5 seconds... (Attempt ${retries + 1}/8)');
          await Future.delayed(const Duration(milliseconds: 1500));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          retries++;
        }
        if (apnsToken == null) {
          debugPrint('APNS token is null (check if Push Capability is added in Xcode and provisioning profiles). Skipping FCM token retrieval.');
          return;
        }
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('Client FCM Token obtained: $token');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('Error uploading client FCM token: $e');
    }
  }

  static Future<void> deleteFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('No FCM token found to delete.');
        return;
      }

      const String mutation = r'''
        mutation DeleteFcmToken($fcmToken: String!) {
          deleteFcmToken(fcmToken: $fcmToken) {
            success
          }
        }
      ''';

      final client = getIt<GraphQLService>().client;
      final options = MutationOptions(
        document: gql(mutation),
        variables: {'fcmToken': token},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        debugPrint('Failed to delete client FCM token: ${result.exception.toString()}');
      } else {
        debugPrint('Client FCM Token deleted successfully from backend.');
      }
    } catch (e) {
      debugPrint('Error calling deleteFcmToken mutation: $e');
    }
  }

  static Future<void> _sendTokenToBackend(String fcmToken) async {
    const String mutation = r'''
      mutation UpdateFcmToken($fcmToken: String!) {
        updateFcmToken(fcmToken: $fcmToken) {
          success
        }
      }
    ''';

    try {
      final client = getIt<GraphQLService>().client;
      final options = MutationOptions(
        document: gql(mutation),
        variables: {'fcmToken': fcmToken},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        debugPrint('Failed to upload client FCM token: ${result.exception.toString()}');
      } else {
        debugPrint('Client FCM Token uploaded successfully.');
      }
    } catch (e) {
      debugPrint('Error calling updateFcmToken mutation in client: $e');
    }
  }
}

