import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mediapark/screens/offline_screen_wrapper.dart';
import 'package:mediapark/screens/version_check_wrapper.dart';
import 'package:mediapark/screens/welcome_screen.dart';
import 'package:mediapark/services/notification_service.dart';

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.notificationService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _handledInitial = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // listenery: foreground + background click
      await widget.notificationService.initFCM();

      // killed -> click
      if (_handledInitial) return;
      _handledInitial = true;

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        await widget.notificationService.handleRemoteMessage(initialMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
