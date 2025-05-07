import 'dart:convert';
import 'package:http/http.dart' as http;

class SamorzadSzczegoly {
  final String name;
  final String address;
  final String phone;
  final String email;
  final double mapLat;
  final double mapLng;
  final String locationStreet;
  final String locationPostalCode;
  final int mapZoom;
  final String logo;
  final List<SamorzadModule> modules;

  SamorzadSzczegoly({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.mapLat,
    required this.mapLng,
    required this.mapZoom,
    required this.locationStreet,
    required this.locationPostalCode,
    required this.logo,
    required this.modules,
  });

  factory SamorzadSzczegoly.fromJson(Map<String, dynamic> json) {
    return SamorzadSzczegoly(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      mapLat: (json['map_lat'] ?? 0).toDouble(),
      mapLng: (json['map_lng'] ?? 0).toDouble(),
      mapZoom: json['map_zoom'] ?? 12,
      locationStreet: json['location_street'] ?? '',
      locationPostalCode: json['location_postal_code'],
      logo: json['logo'] ?? '',
      modules: (json['modules'] as List<dynamic>?)
              ?.map((m) => SamorzadModule.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class SamorzadModule {
  final String type;
  final String url;
  final String alias;

  SamorzadModule({
    required this.type,
    required this.url,
    required this.alias,
  });

  factory SamorzadModule.fromJson(Map<String, dynamic> json) {
    return SamorzadModule(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      alias: json['alias'] ?? '',
    );
  }
}

Future<SamorzadSzczegoly> fetchSzczegolyInstytucji(String id) async {
  final url = 'https://api.wdialogu.pl/v1/i/$id/szczegoly-instytucji';
  const token = 'SiulsrtVRSlrRZVKL1jV17tmGibpHlXMkCScv33OjJQFA2dDApVOWCUPqjXRTsxA';
  // final url = 'http://172.17.59.188:3000/test';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return SamorzadSzczegoly.fromJson(data);
  } else {
    throw Exception('Nie udało się pobrać szczegółów instytucji');
  }
}


