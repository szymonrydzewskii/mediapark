class Samorzad {
  final String id;
  final String nazwa;
  final String herb;

  Samorzad({required this.id, required this.nazwa, required this.herb});

  factory Samorzad.fromJson(Map<String, dynamic> json) => Samorzad(
    id: json['id_institution'].toString(),
    nazwa: json['name'],
    herb: json['logo'],
  );
}
