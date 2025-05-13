import 'package:flutter/material.dart';
import 'package:mediapark/models/samorzad.dart';
import 'screens/selecting_samorzad.dart';
import 'screens/main_window.dart';

class Routes {
  static const selectSamorzad = '/';
  static const mainWindow = '/main';

  static final Map<String, WidgetBuilder> all = {
    selectSamorzad: (_) => const SelectingSamorzad(),
    mainWindow: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Set<Samorzad>) {
        return MainWindow(wybraneSamorzady: args);
      }
      throw ArgumentError('Brak argumentów dla MainWindow');
    },
  };
}