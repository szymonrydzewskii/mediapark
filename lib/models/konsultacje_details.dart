class KonsultacjeDetails {
  final int idConsultation;
  final int idInstitution;
  final int idCategory;
  final int idType;

  final String categoryAlias;
  final String categoryName;

  final String alias;
  final String title;

  final String purposeOfConsultation;
  final String subject;

  final int responsibilityHeader;
  final String responsibilityText;

  final String legalBasis;
  final String whoCanParticipate;

  final int informationHeader;
  final String informationText;

  final String description;
  final String shortDescription;

  final String dateOfConsultationStart; // np "2025-12-17" albo "20.02.2024"
  final String dateOfConsultationEnd;

  final String dateOfConsultationStartFormatted; // np "17.12.2025"
  final String dateOfConsultationEndFormatted;

  final String publishDate;
  final String statusName;

  final int showMap;
  final String mapPoints;
  final String mapPolygons;
  final String mapPolylines;

  final int? idPoll;
  final String? pollUrl;

  final String? photoUrl;

  final List<MainPhoto> mainPhotos;
  final List<KonsultacjaDebata> debates;
  final List<KonsultacjaPlik> files;

  KonsultacjeDetails({
    required this.idConsultation,
    required this.idInstitution,
    required this.idCategory,
    required this.idType,
    required this.alias,
    required this.title,
    required this.purposeOfConsultation,
    required this.subject,
    required this.responsibilityHeader,
    required this.responsibilityText,
    required this.legalBasis,
    required this.whoCanParticipate,
    required this.informationHeader,
    required this.informationText,
    required this.description,
    required this.shortDescription,
    required this.dateOfConsultationStart,
    required this.dateOfConsultationEnd,
    required this.dateOfConsultationStartFormatted,
    required this.dateOfConsultationEndFormatted,
    required this.publishDate,
    required this.statusName,
    required this.showMap,
    required this.mapPoints,
    required this.mapPolygons,
    required this.mapPolylines,
    required this.idPoll,
    required this.pollUrl,
    required this.photoUrl,
    required this.mainPhotos,
    required this.debates,
    required this.files,
    required this.categoryAlias,
    required this.categoryName,
  });

  factory KonsultacjeDetails.fromJson(Map<String, dynamic> json) {
    final mainPhotosJson = (json['main_photos'] as List?) ?? const [];
    final filesJson = (json['files'] as List?) ?? const [];
    final debatesJson = (json['debates'] as List?) ?? const [];

    return KonsultacjeDetails(
      idConsultation: _asInt(json['id_consultation']),
      idInstitution: _asInt(json['id_institution']),
      idCategory: _asInt(json['id_category']),
      idType: _asInt(json['id_type']),
      alias: (json['alias'] ?? '') as String,
      title: (json['title'] ?? '') as String,

      purposeOfConsultation: (json['purpose_of_consultation'] ?? '') as String,
      subject: (json['subject'] ?? '') as String,

      responsibilityHeader: _asInt(json['responsibility_header']),
      responsibilityText: (json['responsibility_text'] ?? '') as String,

      legalBasis: (json['legal_basis'] ?? '') as String,
      whoCanParticipate: (json['who_can_participate'] ?? '') as String,

      informationHeader: _asInt(json['information_header']),
      informationText: (json['information_text'] ?? '') as String,

      description: (json['description'] ?? '') as String,
      shortDescription: (json['short_description'] ?? '') as String,

      dateOfConsultationStart:
          (json['date_of_consultation_start'] ?? '') as String,
      dateOfConsultationEnd: (json['date_of_consultation_end'] ?? '') as String,

      dateOfConsultationStartFormatted:
          (json['date_of_consultation_start_formatted'] ?? '') as String,
      dateOfConsultationEndFormatted:
          (json['date_of_consultation_end_formatted'] ?? '') as String,

      publishDate: (json['publish_date'] ?? '') as String,
      statusName: (json['status_name'] ?? '') as String,

      showMap: _asInt(json['show_map']),
      mapPoints: (json['map_points'] ?? '') as String,
      mapPolygons: (json['map_polygons'] ?? '') as String,
      mapPolylines: (json['map_polylines'] ?? '') as String,

      idPoll: (json['id_poll'] == null) ? null : _asInt(json['id_poll']),
      pollUrl: (json['poll_url'] as String?)?.trim(),

      photoUrl: (json['photo_url'] as String?)?.trim(),
      categoryAlias: (json['category_alias'] ?? '') as String,
      categoryName: (json['category_name'] ?? '') as String,

      mainPhotos:
          mainPhotosJson
              .whereType<Map>()
              .map((e) => MainPhoto.fromJson(Map<String, dynamic>.from(e)))
              .toList(),

      debates:
          debatesJson
              .whereType<Map>()
              .map(
                (e) => KonsultacjaDebata.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(),

      files:
          filesJson
              .whereType<Map>()
              .map(
                (e) => KonsultacjaPlik.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(),
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class MainPhoto {
  final int idPhoto;
  final int idConsultation;
  final int idInstitution;
  final String filename;
  final String extension;

  MainPhoto({
    required this.idPhoto,
    required this.idConsultation,
    required this.idInstitution,
    required this.filename,
    required this.extension,
  });

  factory MainPhoto.fromJson(Map<String, dynamic> json) {
    return MainPhoto(
      idPhoto: _asInt(json['id_photo']),
      idConsultation: _asInt(json['id_consultation']),
      idInstitution: _asInt(json['id_institution']),
      filename: (json['filename'] ?? '') as String,
      extension: (json['extension'] ?? '') as String,
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class KonsultacjaPlik {
  final int idFile;
  final int idInstitution;
  final int idConsultation;
  final String filename;
  final String extension;
  final String description;

  KonsultacjaPlik({
    required this.idFile,
    required this.idInstitution,
    required this.idConsultation,
    required this.filename,
    required this.extension,
    required this.description,
  });

  factory KonsultacjaPlik.fromJson(Map<String, dynamic> json) {
    return KonsultacjaPlik(
      idFile: _asInt(json['id_file']),
      idInstitution: _asInt(json['id_institution']),
      idConsultation: _asInt(json['id_consultation']),
      filename: (json['filename'] ?? '') as String,
      extension: (json['extension'] ?? '') as String,
      description: (json['description'] ?? '') as String,
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class KonsultacjaDebata {
  final int idDebate;
  final int idInstitution;
  final int idConsultation;

  final String dateBegin;
  final String beginTime;
  final String dateEnd;
  final String endTime;

  final String title;
  final String purpose;
  final String place;

  KonsultacjaDebata({
    required this.idDebate,
    required this.idInstitution,
    required this.idConsultation,
    required this.dateBegin,
    required this.beginTime,
    required this.dateEnd,
    required this.endTime,
    required this.title,
    required this.purpose,
    required this.place,
  });

  factory KonsultacjaDebata.fromJson(Map<String, dynamic> json) {
    return KonsultacjaDebata(
      idDebate: _asInt(json['id_debate']),
      idInstitution: _asInt(json['id_institution']),
      idConsultation: _asInt(json['id_consultation']),
      dateBegin: (json['date_of_debate_begin'] ?? '') as String,
      beginTime: (json['date_of_debate_begin_time'] ?? '') as String,
      dateEnd: (json['date_of_debate_end'] ?? '') as String,
      endTime: (json['date_of_debate_end_time'] ?? '') as String,
      title: (json['title_of_debate'] ?? '') as String,
      purpose: (json['purpose_of_debate'] ?? '') as String,
      place: (json['place_of_debate'] ?? '') as String,
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
