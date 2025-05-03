import 'dart:convert';

import 'package:http/http.dart' as http;

class Samorzad {
  final String id;
  final String nazwa;
  final String herb;

  Samorzad({required this.id, required this.nazwa, required this.herb});

  factory Samorzad.fromJson(Map<String, dynamic> json){
    return Samorzad(
        id: json['id'], 
        nazwa: json['nazwa'], 
        herb: json['herb']
      );
  }
}

Future<List<Samorzad>> loadSamorzad() async {
  final url = 'http://localhost:3000/gminy';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Samorzad.fromJson(json)).toList();
  } else {
    throw Exception('Błąd w podłączeniu do API');
  }
}