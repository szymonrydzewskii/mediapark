import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for managing application preferences using SharedPreferences.
/// Provides type-safe access to stored user settings.
class PreferencesHelper {
  // Keys
  static const String _keySamorzady = 'selected_samorzady';
  static const String _keyPushNotifications = 'push_notifications_enabled';

  // Samorzady preferences
  static Future<void> saveSelectedSamorzady(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySamorzady, ids.toList());
  }

  static Future<Set<String>> getSelectedSamorzady() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySamorzady)?.toSet() ?? {};
  }

  static Future<void> clearSelectedSamorzady() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySamorzady);
  }

  // Push notifications preferences
  static Future<void> savePushNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushNotifications, enabled);
  }

  static Future<bool> getPushNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPushNotifications) ?? false;
  }

  // Clear all preferences (useful for logout/reset)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
