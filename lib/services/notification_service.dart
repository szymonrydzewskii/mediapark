import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging msgService = FirebaseMessaging.instance;

  Future<void> initFCM() async {
    final settings = await msgService.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Notification permission: ${settings.authorizationStatus}');

    final token = await msgService.getToken();
    print("📱 FCM TOKEN: $token");

    // Subskrypcja topicu
    await msgService.subscribeToTopic("jst_10");
    print("✅ Subskrybowano topic jst_10");

    // 1. Wiadomość gdy apka jest na ekranie
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 ON_MESSAGE (foreground)');
      print(
        'notification: ${message.notification?.title} / ${message.notification?.body}',
      );
      print('data: ${message.data}');
    });

    // 2. Użytkownik kliknął powiadomienie (appka w tle)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 ON_MESSAGE_OPENED_APP');
      print('data: ${message.data}');
    });

    // 3. Appka była ubita i została otwarta z powiadomienia
    final initialMessage = await msgService.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 INITIAL_MESSAGE');
      print('data: ${initialMessage.data}');
    }
  }
}
