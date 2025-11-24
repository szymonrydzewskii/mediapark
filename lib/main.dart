import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
// import 'firebase_options.dart'; // 👈 generowane przez flutterfire configure
import 'package:mediapark/services/image_cache_service.dart';
import 'package:mediapark/services/hive_data_cache.dart';
import 'package:mediapark/services/notification_service.dart';

/// Handler dla wiadomości w tle (musi być top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('⏪ BACKGROUND MESSAGE: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Inicjalizacja Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // odkomentuj, jeśli używasz flutterfire_cli
  );

  // Rejestracja handlera dla wiadomości w tle
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicjalizacja innych serwisów
  await ImageCacheService.init();
  await Hive.initFlutter();
  await HiveDataCache.init();
  await dotenv.load(fileName: ".env");

  // 📲 Inicjalizacja FCM
  await NotificationService().initFCM();

  // Sprawdź, czy appka została otwarta z powiadomienia (terminated state)
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print('🚀 APP OPENED FROM NOTIFICATION (terminated)');
    print('Data: ${initialMessage.data}');
  }

  runApp(
    ScreenUtilInit(
      designSize: const Size(427, 952),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}
