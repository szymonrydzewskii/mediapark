class SamorzadModule {
  final String type;
  final String url;
  final String alias;

  SamorzadModule({required this.type, required this.url, required this.alias});

  factory SamorzadModule.fromJson(Map<String, dynamic> json) => SamorzadModule(
        type: json['type'] ?? '',
        url: json['url'] ?? '',
        alias: json['alias'] ?? '',
      );
}

class SamorzadSzczegoly {
  final String name;
  final String address;
  final String phone;
  final String email;
  final double mapLat;
  final double mapLng;
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
    required this.logo,
    required this.modules,
  });

  factory SamorzadSzczegoly.fromJson(Map<String, dynamic> json) => SamorzadSzczegoly(
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        mapLat: (json['map_lat'] ?? 0).toDouble(),
        mapLng: (json['map_lng'] ?? 0).toDouble(),
        mapZoom: json['map_zoom'] ?? 12,
        logo: json['logo'] ?? '',
        modules: (json['modules'] as List<dynamic>? ?? [])
            .map((m) => SamorzadModule.fromJson(m))
            .toList(),
      );
}