class BudzetObywatelskiDetails {
  final String name;
  final String? mainPhotoUrl;
  final String? longDescValue;
  final String? additionalDataValue;
  final String? projectStatusValue;
  final String? projectEditionValue;
  final String? projectEstimatedCostValue;
  final String? typeValue;

  BudzetObywatelskiDetails({
    required this.name,
    this.mainPhotoUrl,
    this.longDescValue,
    this.additionalDataValue,
    this.projectStatusValue,
    this.projectEditionValue,
    this.projectEstimatedCostValue,
    this.typeValue,
  });

  factory BudzetObywatelskiDetails.fromJson(Map<String, dynamic> json) {
    return BudzetObywatelskiDetails(
      name: json['name'] ?? '',
      mainPhotoUrl: json['main_photo_url'],
      longDescValue: json['long_desc_value'],
      additionalDataValue: json['additional_data_value'],
      projectStatusValue: json['project_status_value'],
      projectEditionValue: json['project_edition_value'],
      projectEstimatedCostValue: json['project_estimated_cost_value'],
      typeValue: json['type_value'],
    );
  }
}