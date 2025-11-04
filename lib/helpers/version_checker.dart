import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionChecker {
  final String apiUrl;

  VersionChecker({required this.apiUrl});

  Future<String> _getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    final version = info.version;
    final parts = version.split('.');
    return '${parts[0]}.${parts[1]}'; // "1.0.1" -> "1.0"
  }

  Future<String> _getLatestVersion() async {
    final resp = await http.get(Uri.parse(apiUrl));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data['version'] as String;
    } else {
      throw Exception('Failed to fetch latest version');
    }
  }

  bool _isUpdateRequired(String current, String latest) {
    List<int> parseVer(String v) {
      final parts = v.split('.');
      final major = int.tryParse(parts[0]) ?? 0;
      final minor = (parts.length > 1 ? int.tryParse(parts[1]) : null) ?? 0;
      return [major, minor];
    }

    final curr = parseVer(current);
    final lat = parseVer(latest);

    if (curr[0] < lat[0]) return true;
    if (curr[0] > lat[0]) return false;
    return curr[1] < lat[1];
  }

  Future<bool> checkForUpdate({
    required BuildContext context,
    bool showDialog = true,
  }) async {
    try {
      final current = await _getCurrentVersion();
      final latest = await _getLatestVersion();
      if (_isUpdateRequired(current, latest)) {
        if (showDialog) {
          _showUpdateDialog(context);
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nowa wersja dostępna'),
          content: const Text(
            'Dostępna jest nowsza wersja aplikacji. Proszę zaktualizuj.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aktualizuj'),
            ),
          ],
        );
      },
    );
  }
}
