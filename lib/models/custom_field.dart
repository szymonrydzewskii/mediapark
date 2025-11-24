class CustomField {
  final String name;
  final String value;

  CustomField({required this.name, required this.value});

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(name: json['name'] ?? '', value: json['value'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value};
  }
}
