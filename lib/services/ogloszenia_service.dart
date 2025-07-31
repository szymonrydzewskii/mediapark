import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ogloszenia.dart';

class OgloszeniaService {
  final String idInstytucji;

  OgloszeniaService({ required this.idInstytucji});

  Future<List<Ogloszenia>> fetchWszystkie() async {
    final url = 'https://test.wdialogu.pl/v1/i/$idInstytucji/ogloszenia/lista';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Ogloszenia.fromJson(e)).toList();
    } else {
      throw Exception('Nie znaleziono ogłoszeń');
    }
  }

  Future<List<KategoriaOgloszen>> fetchKategorie() async {
    final url = 'https://test.wdialogu.pl/v1/i/$idInstytucji/kategorie-ogloszen';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      return data.values
          .map((e) => KategoriaOgloszen.fromJson(e))
          .toList();
    } else {
      throw Exception('Nie znaleziono ogłoszeń');
    }
  }

  Future<List<Ogloszenia>> fetchZKategorii(int idKategorii) async {
    final url = 'https://test.wdialogu.pl/v1/i/$idInstytucji/ogloszenia/lista/$idKategorii';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Ogloszenia.fromJson(e)).toList();
    } else {
      throw Exception('Nie znaleziono ogłoszeń');
    }
  }
}
