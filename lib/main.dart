import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
// import 'firebase_options.dart'; // 👈 bardzo ważne
import 'package:mediapark/services/image_cache_service.dart';
import 'package:mediapark/services/hive_data_cache.dart';
import 'package:mediapark/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 👇 w tle też musisz zainicjalizować Firebase tak samo
  await Firebase.initializeApp();
  print('⏪ BG MESSAGE: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 główna inicjalizacja Firebase
  await Firebase.initializeApp();

  // handler dla wiadomości w tle – musi być zarejestrowany PRZED użyciem FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // reszta Twojej inicjalizacji
  await ImageCacheService.init();
  await Hive.initFlutter();
  await HiveDataCache.init();
  await dotenv.load(fileName: ".env");

  await NotificationService().initFCM();

  runApp(
    ScreenUtilInit(
      designSize: const Size(427, 952),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}
