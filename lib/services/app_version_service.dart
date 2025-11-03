import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class AppVersionService {
  static const _url = 'https://test.wdialogu.pl/app-version';

  Future<bool> isUpdateRequired() async {
    final info = await PackageInfo.fromPlatform();
    final localVersion = Version.parse(info.version); // np. 1.0.0

    final latestRaw = await AppVersionService().fetchLatestVersion();
    if (latestRaw == null) return false;

    final latestVersion = Version.parse(
      latestRaw.contains('.') ? latestRaw : '$latestRaw.0.0',
    );

    return localVersion < latestVersion;
  }

  Future<String?> fetchLatestVersion() async {
    final response = await http
        .get(Uri.parse(_url))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return json['version'] as String?;
    } else {
      throw Exception('Failed to fetch app version: ${response.statusCode}');
    }
  }
}
