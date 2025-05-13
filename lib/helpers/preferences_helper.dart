import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const _key = 'selected_samorzady';

  static Future<void> saveSelectedSamorzady(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }

  static Future<Set<String>> getSelectedSamorzady() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  static Future<void> clearSelectedSamorzady() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}