// lib/helpers/url_launcher_helper.dart
import 'package:url_launcher/url_launcher.dart';

/// Helper class for launching URLs in external browsers or native apps.
/// Handles social media platforms (Facebook, Instagram, X/Twitter, YouTube)
/// by attempting to open them in their native apps first, falling back to browser.
class UrlLauncherHelper {
  /// List of social media aliases that should open externally
  static const Set<String> _externalAliases = {
    'instagram',
    'facebook',
    'portal-x',
    'youtube',
  };

  /// Checks if the given module alias should open externally
  static bool shouldOpenExternally(String alias) {
    return _externalAliases.contains(alias.toLowerCase());
  }

  /// Launches URL externally, attempting native app first, then browser
  static Future<bool> launchExternalUrl(String url) async {
    if (url.isEmpty) return false;

    final uri = Uri.parse(url);

    // Try to launch in external app (native app if available, otherwise browser)
    try {
      // LaunchMode.externalApplication tries to open in native app first
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      // Fallback: try platform default (browser)
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        return launched;
      } catch (e2) {
        return false;
      }
    }
  }

  /// Checks if URL can be launched before attempting
  static Future<bool> canLaunchExternalUrl(String url) async {
    if (url.isEmpty) return false;
    try {
      return await canLaunchUrl(Uri.parse(url));
    } catch (e) {
      return false;
    }
  }
}
