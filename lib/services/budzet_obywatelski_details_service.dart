import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/budzet_obywatelski_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<BudzetObywatelskiDetails> fetchProjektDetails(int idProject) async {
  final url = 'https://gminy.budzet-obywatelski.eu/mobile-app-api/v1/i/201/projekt/$idProject';
  final token = dotenv.env['API_TOKEN_BUDZET'];

  final res = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (res.statusCode == 200) {
    final jsonMap = jsonDecode(res.body);
    return BudzetObywatelskiDetails.fromJson(jsonMap);
  }

  throw Exception('Błąd pobierania szczegółów: ${res.statusCode}');
}