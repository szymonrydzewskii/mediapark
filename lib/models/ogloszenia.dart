class Ogloszenia {
  final int id;
  final String alias;
  final String title;
  final String intro;
  final String? mainPhoto;
  final String datetime;
  final String? categoryName;
  final int? idCategory;

  Ogloszenia({
    required this.id,
    required this.alias,
    required this.title,
    required this.intro,
    this.mainPhoto,
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
  final List<GalleryFile> gallery;
  final List<OtherFile> otherFiles;

  OgloszeniaDetails({
    required this.id,
    required this.alias,
    required this.title,
    required this.content,
    required this.datetime,
    this.mapPoints,
    this.mapPolylines,
    this.mapPolygons,
    required this.gallery,
    required this.otherFiles,
  });

  factory OgloszeniaDetails.fromJson(Map<String, dynamic> json) {
    final files = json['files'] as Map<String, dynamic>;
    final galleryList = files['gallery'] as List? ?? [];
    final otherList = files['other'] as List? ?? [];

    return OgloszeniaDetails(
      id: json['id_announcement'],
      alias: json['alias'],
      title: json['title'],
      content: json['content'],
      datetime: json['datetime_of_add'],
      mapPoints:
          json['map_points']?.isNotEmpty == true ? json['map_points'] : null,
      mapPolylines:
          json['map_polylines']?.isNotEmpty == true
              ? json['map_polylines']
              : null,
      mapPolygons:
          json['map_polygons']?.isNotEmpty == true
              ? json['map_polygons']
              : null,
      gallery: galleryList.map((e) => GalleryFile.fromJson(e)).toList(),
      otherFiles: otherList.map((e) => OtherFile.fromJson(e)).toList(),
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
