import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/budzet_obywatelski.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<BudzetObywatelski>> fetchProjekty(String id) async {
  final url =
      'https://gminy.budzet-obywatelski.eu/mobile-app-api/v1/i/201/projekty';
  final token = dotenv.env['API_TOKEN_BUDZET'];

  final res = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  if (res.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(res.body);
    return jsonList.map((json) => BudzetObywatelski.fromJson(json)).toList();
  }

  throw Exception('Błąd pobierania projektów: ${res.statusCode}');
}
