import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/samorzad_details.dart';

Future<SamorzadSzczegoly> fetchSzczegolyInstytucji(String id) async {
  final url = 'https://api.wdialogu.pl/v1/i/$id/szczegoly-instytucji';
  const token = 'SiulsrtVRSlrRZVKL1jV17tmGibpHlXMkCScv33OjJQFA2dDApVOWCUPqjXRTsxA';
  final res = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  });
  if (res.statusCode == 200) {
    return SamorzadSzczegoly.fromJson(jsonDecode(res.body));
  }
  throw Exception('Błąd: ${res.statusCode}');
}