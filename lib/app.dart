import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes.dart';

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
      initialRoute: Routes.selectSamorzad,
      routes: Routes.all,
    );
  }
}