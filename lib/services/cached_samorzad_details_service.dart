import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/samorzad_details.dart';
import 'hive_data_cache.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CachedSamorzadDetailsService {
  static const String _baseUrl = 'https://api.wdialogu.pl/v1';

  static String _getCacheKey(String samorzadId) => 'samorzad_details_$samorzadId';

  Future<SamorzadSzczegoly> fetchSzczegolyInstytucji(
    String id, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = _getCacheKey(id);

    // Sprawdź cache jeśli nie wymuszamy odświeżenia
    if (!forceRefresh) {
      final cached = await HiveDataCache.getObject<SamorzadSzczegoly>(
        cacheKey,
        (json) => SamorzadSzczegoly.fromJson(json),
        maxAge: const Duration(hours: 2),
      );

      if (cached != null) {
        return cached;
      }
    }

    // Pobierz z API
    try {
      final token = dotenv.env['API_TOKEN_WDIALOGU'];
      final url = '$_baseUrl/i/$id/szczegoly-instytucji';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final szczegoly = SamorzadSzczegoly.fromJson(data);

        // Zapisz w cache surowe dane JSON
        await HiveDataCache.setObject(cacheKey, data);

        return szczegoly;
      } else {
        throw Exception('Błąd API: ${response.statusCode}');
      }
    } catch (e) {
      // Jeśli API nie działa, spróbuj zwrócić stary cache
      final oldCache = await HiveDataCache.getObject<SamorzadSzczegoly>(
        cacheKey,
        (json) => SamorzadSzczegoly.fromJson(json),
        maxAge: const Duration(days: 7), // Długi cache w przypadku błędu
      );

      if (oldCache != null) {
        return oldCache;
      }

      rethrow;
    }
  }

  /// Usuwa cache dla konkretnego samorządu
  Future<void> clearCache(String samorzadId) async {
    final cacheKey = _getCacheKey(samorzadId);
    await HiveDataCache.delete(cacheKey);
  }

  /// Usuwa cache dla wszystkich samorządów
  Future<void> clearAllCache() async {
    await HiveDataCache.clear();
  }
}