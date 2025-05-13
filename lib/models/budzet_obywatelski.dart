import 'custom_field.dart';

class BudzetObywatelski {
  final int idProject;
  final int status;
  final String statusName;
  final String name;
  final String shortDescription;
  final bool categoryVisible;
  final bool typeVisible;
  final String typeLabel;
  final String typeValue;
  final bool recipientsVisible;
  final bool quartersVisible;
  final String quartersLabel;
  final String quartersValue;
  final bool customFieldsVisible;
  final List<CustomField> customFields;
  final bool costVisible;
  final String costLabel;
  final String costValue;
  final bool mergedProjectsVisible;
  final bool authorsVisible;

  BudzetObywatelski({
    required this.idProject,
    required this.status,
    required this.statusName,
    required this.name,
    required this.shortDescription,
    required this.categoryVisible,
    required this.typeVisible,
    required this.typeLabel,
    required this.typeValue,
    required this.recipientsVisible,
    required this.quartersVisible,
    required this.quartersLabel,
    required this.quartersValue,
    required this.customFieldsVisible,
    required this.customFields,
    required this.costVisible,
    required this.costLabel,
    required this.costValue,
    required this.mergedProjectsVisible,
    required this.authorsVisible,
  });

  factory BudzetObywatelski.fromJson(Map<String, dynamic> json) {
    return BudzetObywatelski(
      idProject: json['id_project'] as int,
      status: json['status'] as int,
      statusName: json['status_name'] ?? '',
      name: json['name'] ?? '',
      shortDescription: json['short_description'] ?? '',
      categoryVisible: json['category_visible'] ?? false,
      typeVisible: json['type_visible'] ?? false,
      typeLabel: json['type_label'] ?? '',
      typeValue: json['type_value'] ?? '',
      recipientsVisible: json['recipients_visible'] ?? false,
      quartersVisible: json['quarters_visible'] ?? false,
      quartersLabel: json['quarters_label'] ?? '',
      quartersValue: json['quarters_value'] ?? '',
      customFieldsVisible: json['custom_fields_visible'] ?? false,
      customFields:
          (json['custom_fields'] as List<dynamic>?)
              ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      costVisible: json['cost_visible'] ?? false,
      costLabel: json['cost_label'] ?? '',
      costValue: json['cost_value'] ?? '',
      mergedProjectsVisible: json['merged_projects_visible'] ?? false,
      authorsVisible: json['authors_visible'] ?? false,
    );
  }
}
