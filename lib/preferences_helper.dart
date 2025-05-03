import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const _selectedSamorzadyKey = 'selected_samorzady';

  static Future<void> saveSelectedSamorzady(
    Set<String> wybraneSamorzady,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_selectedSamorzadyKey, wybraneSamorzady.toList());
  }

  static Future<Set<String>> getSelectedSamorzady() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_selectedSamorzadyKey);
    return list?.toSet() ?? {};
  }

  static Future<void> clearSelectedSamorzady() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedSamorzadyKey);
  }
}
