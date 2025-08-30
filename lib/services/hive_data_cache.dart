import 'package:hive_flutter/hive_flutter.dart';

class HiveDataCache {
  static Box? _dataBox;

  static Future<void> init() async {
    _dataBox = await Hive.openBox('data_cache');
  }

  static Future<List<T>?> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson, {
    Duration maxAge = const Duration(hours: 2),
  }) async {
    if (_dataBox == null) return null;

    final cached = _dataBox!.get(key);
    if (cached == null) return null;

    try {
      final data = Map<String, dynamic>.from(cached);
      final timestamp = DateTime.parse(data['timestamp']);

      if (DateTime.now().difference(timestamp) > maxAge) {
        await _dataBox!.delete(key);
        return null;
      }

      final List<dynamic> items = data['items'];
      return items
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      await _dataBox!.delete(key);
      return null;
    }
  }

  static Future<void> setList<T>(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    if (_dataBox == null) return;

    await _dataBox!.put(key, {
      'items': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> clear() async {
    await _dataBox?.clear();
  }

  static Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson, {
    Duration maxAge = const Duration(hours: 2),
  }) async {
    if (_dataBox == null) return null;

    final cached = _dataBox!.get(key);
    if (cached == null) return null;

    try {
      final data = Map<String, dynamic>.from(cached);
      final timestamp = DateTime.parse(data['timestamp']);

      if (DateTime.now().difference(timestamp) > maxAge) {
        await _dataBox!.delete(key);
        return null;
      }

      return fromJson(Map<String, dynamic>.from(data['item']));
    } catch (e) {
      await _dataBox!.delete(key);
      return null;
    }
  }

  static Future<void> setObject(String key, Map<String, dynamic> data) async {
    if (_dataBox == null) return;
    await _dataBox!.put(key, {
      'item': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
