import 'dart:convert';
import 'package:http/http.dart' as http;

class Samorzad {
  final String id;
  final String nazwa;
  final String herb;
  final bool konsultacje;

  Samorzad({required this.id, required this.nazwa, required this.herb, required this.konsultacje});

  factory Samorzad.fromJson(Map<String, dynamic> json){
    return Samorzad(
        id: json['id_institution'].toString(), 
        nazwa: json['name'], 
        herb: json['logo'],
        konsultacje: json['konsultacje']
      );
  }
}

Future<List<Samorzad>> loadSamorzad() async {

  final url = 'http://192.168.0.112:3000/gminy';
  // final url = 'https://api.wdialogu.pl/v1/instytucje/lista';
  // const token = 'SiulsrtVRSlrRZVKL1jV17tmGibpHlXMkCScv33OjJQFA2dDApVOWCUPqjXRTsxA';
  final response = await http.get(
      Uri.parse(url),
      // headers: {
      //   'Authorization' : 'Bearer $token',
      //   'Accept' : 'application/json'
      // }
    );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Samorzad.fromJson(json)).toList();
  } else {
    throw Exception('Błąd w podłączeniu do API');
  }
}