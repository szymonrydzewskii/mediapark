// lib/models/samorzad_details.dart

class SamorzadModule {
  final String type;
  final String url;
  final String alias;
  final String
  idInstytucji; // może być pusty string, jeśli nie wstrzykniesz go niżej

  SamorzadModule({
    required this.type,
    required this.url,
    required this.alias,
    required this.idInstytucji,
  });

  factory SamorzadModule.fromJson(Map<String, dynamic> json) => SamorzadModule(
    type: (json['type'] ?? '').toString(),
    url: (json['url'] ?? '').toString(),
    alias: (json['alias'] ?? '').toString(),
    idInstytucji: (json['id_bo_institution'] ?? '').toString(),
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
  final int idBoInstitution;

  // NOWE POLA:
  final String regulationsLink;
  final String privacyPolicyLink;
  final String accessibilityDeclarationLink;

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
    required this.idBoInstitution,
    required this.regulationsLink,
    required this.privacyPolicyLink,
    required this.accessibilityDeclarationLink,
  });

  factory SamorzadSzczegoly.fromJson(Map<String, dynamic> json) {
    final modulesJson =
        (json['modules'] as List? ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

    return SamorzadSzczegoly(
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      mapLat: (json['map_lat'] ?? 0).toDouble(),
      mapLng: (json['map_lng'] ?? 0).toDouble(),
      mapZoom: (json['map_zoom'] ?? 12) as int,
      logo: (json['logo'] ?? '').toString(),
      modules: modulesJson.map(SamorzadModule.fromJson).toList(),
      idBoInstitution: (json['id_bo_institution'] ?? 0) as int,

      // Mapowanie nowych pól:
      regulationsLink: (json['regulations_link'] ?? '').toString(),
      privacyPolicyLink: (json['privacy_policy_link'] ?? '').toString(),
      accessibilityDeclarationLink:
          (json['accessibility_declaration_link'] ?? '').toString(),
    );
  }
}
