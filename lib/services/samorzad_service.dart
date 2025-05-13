import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/samorzad.dart';

Future<List<Samorzad>> loadSamorzad() async {
  const url = 'https://api.wdialogu.pl/v1/instytucje/lista';
  const token = 'SiulsrtVRSlrRZVKL1jV17tmGibpHlXMkCScv33OjJQFA2dDApVOWCUPqjXRTsxA';
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