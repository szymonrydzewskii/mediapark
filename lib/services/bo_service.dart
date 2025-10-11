import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bo_projekt.dart';
import '../models/bo_harmonogram.dart';

class BOService {
  final int institutionId;
  final String token;

  BOService({
    required this.institutionId,
    this.token =
        "oXZrwOEvhEwBiLMMujzJfaLDSZakQr5IZ9XCap4cmASclvBsjEMhdRLttBiv7IRy",
  });

  Future<List<BOProjekt>> fetchProjekty() async {
    final url =
        'https://test.budzetobywatelski.pl/mobile-app-api/v1/i/$institutionId/projekty';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => BOProjekt.fromJson(e)).toList();
    } else {
      throw Exception('Nie udało się pobrać projektów BO');
    }
  }

  Future<BOHarmonogram> fetchHarmonogram() async {
    final url =
        'https://test.budzetobywatelski.pl/mobile-app-api/v1/i/$institutionId/harmonogram';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return BOHarmonogram.fromJson(data);
    } else {
      throw Exception(
        'Nie udało się pobrać harmonogramu BO: ${res.statusCode} - ${res.body}',
      );
    }
  }
}
