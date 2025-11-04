import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mediapark/screens/offline_screen_wrapper.dart';
import 'package:mediapark/screens/version_check_wrapper.dart';
import 'package:mediapark/screens/welcome_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('pl', 'PL')],
      locale: const Locale('pl', 'PL'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, child) {
        return VersionCheckWrapper(child: OfflineScreenWrapper(child: child!));
      },
      home: const WelcomeScreen(),
    );
  }
}
