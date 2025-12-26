// lib/models/samorzad_details.dart

int _toInt(dynamic v, {int def = 0}) {
  if (v == null) return def;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? def;
}

double _toDouble(dynamic v, {double def = 0.0}) {
  if (v == null) return def;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? def;
}

String _toStr(dynamic v, {String def = ''}) => v?.toString() ?? def;

class SamorzadModule {
  final String type;
  final String url;
  final String alias;

  /// Jeśli potrzebujesz, może być null/"" – bo w modules w API tego nie ma
  final String? idInstytucji;

  SamorzadModule({
    required this.type,
    required this.url,
    required this.alias,
    this.idInstytucji,
  });

  factory SamorzadModule.fromJson(
    Map<String, dynamic> json, {
    String? parentId,
  }) {
    return SamorzadModule(
      type: _toStr(json['type']),
      url: _toStr(json['url']),
      alias: _toStr(json['alias']),
      idInstytucji: parentId ?? _toStr(json['id_bo_institution']),
    );
  }
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
    final parentIdStr = _toStr(json['id_bo_institution']);
    final modulesList =
        (json['modules'] as List? ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

    return SamorzadSzczegoly(
      name: _toStr(json['name']),
      address: _toStr(json['address']),
      phone: _toStr(json['phone']),
      email: _toStr(json['email']),
      mapLat: _toDouble(json['map_lat']),
      mapLng: _toDouble(json['map_lng']),
      mapZoom: _toInt(json['map_zoom'], def: 12),
      logo: _toStr(json['logo']),
      idBoInstitution: _toInt(json['id_bo_institution']),
      modules:
          modulesList
              .map((m) => SamorzadModule.fromJson(m, parentId: parentIdStr))
              .toList(),
      regulationsLink: _toStr(json['regulations_link']),
      privacyPolicyLink: _toStr(json['privacy_policy_link']),
      accessibilityDeclarationLink: _toStr(
        json['accessibility_declaration_link'],
      ),
    );
  }
}
