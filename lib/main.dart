import 'package:flutter/material.dart';
import 'package:mediapark/selecting_samorzad.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('pl', 'PL')],
      locale: Locale('pl', 'PL'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: SelectingSamorzad(),
    );
  }
}
