import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/konsultacje.dart';

class KonsultacjeService {
  static const String _baseUrl = 'https://test.wdialogu.pl/v1/i/10/konsultacje/lista';

  Future<Map<String, List<Konsultacje>>> fetchKonsultacje() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return {
        'planned': (data['planned'] as List)
            .map((item) => Konsultacje.fromJson(item))
            .toList(),
        'active': (data['active'] as List)
            .map((item) => Konsultacje.fromJson(item))
            .toList(),
        'finished': (data['finished'] as List)
            .map((item) => Konsultacje.fromJson(item))
            .toList(),
      };
    } else {
      throw Exception('Nie udało się pobrać konsultacji');
    }
  }
}
