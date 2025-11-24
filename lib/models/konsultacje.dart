class Konsultacje {
  final int id;
  final String alias;
  final String title;
  final String shortDescription;
  final String description;
  final String categoryName;
  final String categoryAlias;
  final String? photoUrl;
  final String? pollUrl;
  final String startDate;
  final String endDate;
  final String status;

  Konsultacje({
    required this.id,
    required this.alias,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.categoryName,
    required this.categoryAlias,
    required this.photoUrl,
    required this.pollUrl,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Konsultacje.fromJson(Map<String, dynamic> json) {
    return Konsultacje(
      id: json['id_consultation'] ?? 0,
      alias: json['alias'] ?? '',
      title: json['title'] ?? '',
      shortDescription: json['short_description'] ?? '',
      description: json['description'] ?? '',
      categoryName: json['category_name'] ?? '',
      categoryAlias: json['category_alias'] ?? '',
      photoUrl: json['photo_url']?.toString(), // <-- nullable
      pollUrl: json['poll_url']?.toString(), // <-- nullable
      startDate: json['date_of_consultation_start_formatted'] ?? '',
      endDate: json['date_of_consultation_end_formatted'] ?? '',
      status: json['status_name'] ?? '',
    );
  }
}
