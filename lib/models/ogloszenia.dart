class Ogloszenia {
  final int id;
  final String alias;
  final String title;
  final String intro;
  final String? mainPhoto;
  final String? photoUrl;
  final String datetime;
  final String? categoryName;
  final int? idCategory;

  Ogloszenia({
    required this.id,
    required this.alias,
    required this.title,
    required this.intro,
    this.mainPhoto,
    this.photoUrl,
    required this.datetime,
    this.categoryName,
    this.idCategory,
  });

  factory Ogloszenia.fromJson(Map<String, dynamic> json) {
    return Ogloszenia(
      id: json['id_announcement'],
      alias: json['alias'],
      title: json['title'],
      intro: json['intro'],
      mainPhoto: json['main_photo'],
      photoUrl: json['photo_url'],
      datetime: json['datetime_of_add'],
      categoryName: json['category_name'],
      idCategory: json['id_category'],
    );
  }
}

class OgloszeniaDetails {
  final int id;
  final String alias;
  final String title;
  final String content;
  final String datetime;

  final String? mapPoints;
  final String? mapPolylines;
  final String? mapPolygons;

  final String? photoUrl; // okładka na kafelku
  final List<GalleryFile> gallery; // zdjęcia
  final List<OtherFile> otherFiles; // załączniki do pobrania

  OgloszeniaDetails({
    required this.id,
    required this.alias,
    required this.title,
    required this.content,
    required this.datetime,
    this.mapPoints,
    this.mapPolylines,
    this.mapPolygons,
    this.photoUrl,
    required this.gallery,
    required this.otherFiles,
  });

  static bool _isImageUrl(String url) {
    final u = url.split('?').first.toLowerCase();
    return u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.png') ||
        u.endsWith('.webp') ||
        u.endsWith('.gif') ||
        u.endsWith('.bmp') ||
        u.endsWith('.svg');
  }

  factory OgloszeniaDetails.fromJson(Map<String, dynamic> json) {
    final filesRaw = json['files'];

    List<dynamic> galleryRaw = [];
    List<dynamic> otherRaw = [];

    if (filesRaw is Map<String, dynamic>) {
      galleryRaw = (filesRaw['gallery'] as List? ?? []);
      otherRaw = (filesRaw['other'] as List? ?? []);
    } else if (filesRaw is List) {
      for (final e in filesRaw) {
        final m = Map<String, dynamic>.from(e as Map);
        final filename = (m['filename'] ?? '').toString();
        if (_isImageUrl(filename)) {
          galleryRaw.add(m);
        } else {
          otherRaw.add(m);
        }
      }
    }

    // ✅ usuń duplikaty po URL pliku
    final seen = <String>{};
    final uniqueGallery = <Map<String, dynamic>>[];

    for (final e in galleryRaw) {
      final m = Map<String, dynamic>.from(e as Map);
      final url = (m['filename'] ?? '').toString().trim();
      if (url.isEmpty) continue;

      final normalized = url.split('?').first; // ignoruj query string
      if (seen.add(normalized)) uniqueGallery.add(m);
    }

    return OgloszeniaDetails(
      id: json['id_announcement'],
      alias: (json['alias'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      datetime: (json['datetime_of_add'] ?? '').toString(),
      mapPoints:
          (json['map_points']?.toString().isNotEmpty == true)
              ? json['map_points'].toString()
              : null,
      mapPolylines:
          (json['map_polylines']?.toString().isNotEmpty == true)
              ? json['map_polylines'].toString()
              : null,
      mapPolygons:
          (json['map_polygons']?.toString().isNotEmpty == true)
              ? json['map_polygons'].toString()
              : null,
      photoUrl:
          (json['photo_url']?.toString().isNotEmpty == true)
              ? json['photo_url'].toString()
              : null,

      // 👇 tu używasz uniqueGallery zamiast galleryRaw
      gallery: uniqueGallery.map((e) => GalleryFile.fromJson(e)).toList(),

      otherFiles:
          otherRaw
              .map(
                (e) => OtherFile.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList(),
    );
  }
}

class GalleryFile {
  final int id;
  final String filename;
  final String description;

  GalleryFile({
    required this.id,
    required this.filename,
    required this.description,
  });

  factory GalleryFile.fromJson(Map<String, dynamic> json) {
    return GalleryFile(
      id: json['id_file'],
      filename: json['filename'],
      description: json['description'],
    );
  }
}

class OtherFile {
  final int id;
  final String filename;
  final String description;

  OtherFile({
    required this.id,
    required this.filename,
    required this.description,
  });

  factory OtherFile.fromJson(Map<String, dynamic> json) {
    return OtherFile(
      id: json['id_file'],
      filename: json['filename'],
      description: json['description'],
    );
  }
}

class KategoriaOgloszen {
  final int id;
  final String name;

  KategoriaOgloszen({required this.id, required this.name});

  factory KategoriaOgloszen.fromJson(Map<String, dynamic> json) {
    return KategoriaOgloszen(
      id: json['id_category'],
      name: json['category_name'],
    );
  }
}
