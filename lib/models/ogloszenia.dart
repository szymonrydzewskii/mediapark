class Ogloszenia {
  final int id;
  final String alias;
  final String title;
  final String intro;
  final String? mainPhoto;
  final String datetime;
  final String? categoryName; 

  Ogloszenia({
    required this.id,
    required this.alias,
    required this.title,
    required this.intro,
    this.mainPhoto,
    required this.datetime,
    this.categoryName, // ← DODANE
  });

  factory Ogloszenia.fromJson(Map<String, dynamic> json) {
    return Ogloszenia(
      id: json['id_announcement'],
      alias: json['alias'],
      title: json['title'],
      intro: json['intro'],
      mainPhoto: json['main_photo'],
      datetime: json['datetime_of_add'],
      categoryName: json['category_name'], // ← DODANE
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