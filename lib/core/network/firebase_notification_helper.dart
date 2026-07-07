import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:clanship_cliente/firebase_options.dart';

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

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground client push notification received: ${message.notification?.title} - ${message.notification?.body}');
      });

      // Handle background/terminated state messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Error initializing Firebase Push Notifications in client: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Background client message received: ${message.messageId}');
  }

  static Future<void> uploadFcmToken() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        int retries = 0;
        while (apnsToken == null && retries < 3) {
          debugPrint('APNS token not set yet. Waiting 1 second... (Attempt ${retries + 1}/3)');
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          retries++;
        }
        if (apnsToken == null) {
          debugPrint('APNS token is null (this is expected on iOS simulators or if APNS is not configured). Skipping FCM token retrieval.');
          return;
        }
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('Client FCM Token: $token');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('Error uploading client FCM token: $e');
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
