import 'package:mediapark/models/konsultacje.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Konsultacje>> fetchKonsultacje() async {
  const url = 'https://test.wdialogu.pl/v1/i/10/konsultacje/lista';
  const token = 'oXZrwOEvhEwBiLMMujzJfaLDSZakQr5IZ9XCap4cmASclvBsjEMhdRLttBiv7IRy';

  final res = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  });

  if (res.statusCode == 200) {
    final json = jsonDecode(res.body);
    final List<Konsultacje> all = [];

    for (final status in ['planned', 'active', 'finished']) {
      if (json[status] != null) {
        all.addAll(
          (json[status] as List)
              .map((e) => Konsultacje.fromJson(e, status))
              .toList(),
        );
      }
    }

    return all;
  } else {
    throw Exception('Błąd ładowania konsultacji');
  }
}
