import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/samorzad.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<Samorzad>> loadSamorzad() async {
  const url = 'https://api.wdialogu.pl/v1/instytucje/lista';
  final token = dotenv.env['API_TOKEN_WDIALOGU'];
  final res = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  });
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Samorzad.fromJson(e)).toList();
  }
  throw Exception('Błąd API: ${res.statusCode}');
}