class BOHarmonogram {
  final List<Phase> phases;

  BOHarmonogram({required this.phases});

  factory BOHarmonogram.fromJson(List<dynamic> jsonList) {
    final phases =
        jsonList.map((e) => Phase.fromJson(e as Map<String, dynamic>)).toList();
    return BOHarmonogram(phases: phases);
  }
}

class Phase {
  final String name;
  final String date;
  final String dateFrom;
  final String dateTo;
  final bool isActive;
  final String? actionType;
  final String? actionUrlAnchor;
  final String? alias;
  final String? actionUrl;
  final bool showCounter;
  final String counterText;

  Phase({
    required this.name,
    required this.date,
    required this.dateFrom,
    required this.dateTo,
    required this.isActive,
    required this.actionType,
    required this.actionUrlAnchor,
    required this.alias,
    required this.actionUrl,
    required this.showCounter,
    required this.counterText,
  });

  factory Phase.fromJson(Map<String, dynamic> json) {
    return Phase(
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      dateFrom: json['date_from'] ?? '',
      dateTo: json['date_to'] ?? '',
      isActive: json['is_active'] ?? false,
      actionType: json['action_type'],
      actionUrlAnchor: json['action_url_anchor'],
      alias: json['alias'] ?? '',
      actionUrl: json['action_url'],
      showCounter: json['show_counter'] ?? false,
      counterText: json['counter_text'] ?? '',
    );
  }
}
