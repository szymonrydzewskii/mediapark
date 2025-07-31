class BOProjekt {
  final int id;
  final String name;
  final String? cost;

  BOProjekt({
    required this.id,
    required this.name,
    this.cost,
  });

  factory BOProjekt.fromJson(Map<String, dynamic> json) {
    return BOProjekt(
      id: json['id_project'],
      name: json['name'],
      cost: json['cost_value']?.replaceAll('&nbsp;', ' '),
    );
  }
}
