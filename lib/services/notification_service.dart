import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _msgService = FirebaseMessaging.instance;

  Future<void> initFCM() async {
    try {
      // 1. Poproś o uprawnienia (krytyczne na iOS)
      final settings = await _msgService.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false, // iOS 12+: "ciche" pozwolenie
      );

      print('🔔 Authorization status: ${settings.authorizationStatus.name}');

      // 2. Sprawdź, czy użytkownik pozwolił
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('⛔ Użytkownik odrzucił powiadomienia');
        return;
      }

      // 3. Pobierz token FCM (na iOS wymaga APNs token)
      final token = await _msgService.getToken();
      if (token == null) {
        print('❌ Nie udało się pobrać FCM tokenu (sprawdź APNs)');
        return;
      }
      print("📱 FCM TOKEN: $token");

      // 4. Subskrypcja topicu
      await _msgService.subscribeToTopic("jst_10");
      print("✅ Subskrybowano topic: jst_10");

      // 5. Handlery wiadomości
      _setupMessageHandlers();
    } catch (e) {
      print('❌ Błąd inicjalizacji FCM: $e');
    }
  }

  void _setupMessageHandlers() {
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 FOREGROUND MESSAGE');
      _logMessage(message);
    });

    // Opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 OPENED FROM BACKGROUND');
      _logMessage(message);
    });

    // Opened from terminated state (sprawdź w main())
  }

  void _logMessage(RemoteMessage message) {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}
