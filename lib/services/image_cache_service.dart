import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';

class ImageCacheService {
  static Box? _imageBox;
  static const int maxCacheSize = 50;

  static Future<void> init() async {
    await Hive.initFlutter(); // Dodaj tę linię
    _imageBox = await Hive.openBox('image_cache');
  }

  static Future<Uint8List?> getImage(String url) async {
    if (_imageBox == null || url.isEmpty) return null;

    final cached = _imageBox!.get(url);
    if (cached == null) return null;

    try {
      final data = Map<String, dynamic>.from(cached);
      final timestamp = DateTime.parse(data['timestamp']);

      // Cache na 24 godziny
      if (DateTime.now().difference(timestamp) > const Duration(hours: 24)) {
        await _imageBox!.delete(url);
        return null;
      }

      return Uint8List.fromList(List<int>.from(data['bytes']));
    } catch (e) {
      await _imageBox!.delete(url);
      return null;
    }
  }

  static Future<void> cacheImage(String url, Uint8List bytes) async {
    if (_imageBox == null) return;

    // Sprawdź limit rozmiaru
    if (_imageBox!.length >= maxCacheSize) {
      final keys = _imageBox!.keys.toList();
      await _imageBox!.delete(keys.first);
    }

    await _imageBox!.put(url, {
      'bytes': bytes,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> clearImageCache() async {
    await _imageBox?.clear();
  }
}
