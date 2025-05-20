import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mediapark/helpers/preferences_helper.dart';
import 'package:mediapark/screens/main_window.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import 'package:mediapark/services/samorzad_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> resolveStartScreen() async {
    final wybraneIds = await PreferencesHelper.getSelectedSamorzady();
    if (wybraneIds.isNotEmpty) {
      final wszystkie = await loadSamorzad();
      final wybrane = wszystkie.where((s) => wybraneIds.contains(s.id)).toSet();
      return MainWindow(wybraneSamorzady: wybrane);
    } else {
      return const SelectingSamorzad();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: resolveStartScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: const [Locale('pl', 'PL')],
          locale: const Locale('pl', 'PL'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: snapshot.data,
        );
      },
    );
  }
}
