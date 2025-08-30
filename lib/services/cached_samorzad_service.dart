import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/samorzad.dart';
import 'hive_data_cache.dart';

class CachedSamorzadService {
  static const String _baseUrl = 'https://api.wdialogu.pl/v1';
  static const String _token =
      "SiulsrtVRSlrRZVKL1jV17tmGibpHlXMkCScv33OjJQFA2dDApVOWCUPqjXRTsxA";
  static const String _cacheKey = 'samorzady_list';

  Future<List<Samorzad>> loadSamorzad({bool forceRefresh = false}) async {
    // Sprawdź cache jeśli nie wymuszamy odświeżenia
    if (!forceRefresh) {
      final cached = await HiveDataCache.getList<Samorzad>(
        _cacheKey,
        (json) => Samorzad.fromJson(json),
        maxAge: const Duration(hours: 4),
      );

      if (cached != null) {
        return cached;
      }
    }

    // Pobierz z API
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/instytucje/lista'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final samorzady = data.map((e) => Samorzad.fromJson(e)).toList();

        // Zapisz w cache surowe dane JSON
        await HiveDataCache.setList(
          _cacheKey,
          List<Map<String, dynamic>>.from(data),
        );

        return samorzady;
      } else {
        throw Exception('Błąd API: ${response.statusCode}');
      }
    } catch (e) {
      // Jeśli API nie działa, spróbuj zwrócić stary cache
      final oldCache = await HiveDataCache.getList<Samorzad>(
        _cacheKey,
        (json) => Samorzad.fromJson(json),
        maxAge: const Duration(days: 7), // Długi cache w przypadku błędu
      );

      if (oldCache != null) {
        return oldCache;
      }

      rethrow;
    }
  }
}
