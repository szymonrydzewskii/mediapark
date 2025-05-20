class Konsultacje {
  final int id;
  final String title;
  final String description;
  final String status;
  final String? photoUrl;

  Konsultacje({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.photoUrl,
  });

  factory Konsultacje.fromJson(Map<String, dynamic> json, String status) {
    return Konsultacje(
      id: json['id_consultation'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: status,
      photoUrl: json['photo_url'],
    );
  }
}
