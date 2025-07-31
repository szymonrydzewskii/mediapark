import 'package:mediapark/helpers/html_helper.dart';

class BOHarmonogram {
  final List<Phase> phases;

  BOHarmonogram({required this.phases});

  factory BOHarmonogram.fromJson(Map<String, dynamic> json) {
    final labels = json['labels'] as Map<String, dynamic>? ?? {};

    // Utility to safely extract and clean up label text
    String text(String key) =>
        (labels[key] as String? ?? '').replaceAll('<br />', ' ');

    // Build a list of phases dynamically based on known JSON keys
    final phases = <Phase>[];

    // Promo phase
    phases.add(
      Phase(
        key: 'promo_name',
        rawName: text('promo_name'),
        start: json['promo_start'] as String? ?? '',
        end: json['add_projects_start'] as String? ?? '',
      ),
    );

    // Add projects phase
    phases.add(
      Phase(
        key: 'add_projects_name',
        rawName: text('add_projects_name'),
        start: json['add_projects_start'] as String? ?? '',
        end: json['verification_projects_start'] as String? ?? '',
      ),
    );

    // Verification phase
    phases.add(
      Phase(
        key: 'verification_projects_name',
        rawName: text('verification_projects_name'),
        start: json['verification_projects_start'] as String? ?? '',
        end: json['choosing_projects_for_voting_start'] as String? ?? '',
      ),
    );

    // Choosing projects phase
    phases.add(
      Phase(
        key: 'choosing_projects_for_voting_name',
        rawName: text('choosing_projects_for_voting_name'),
        start: json['choosing_projects_for_voting_start'] as String? ?? '',
        end: json['voting_for_projects_start'] as String? ?? '',
      ),
    );

    // Voting phase
    phases.add(
      Phase(
        key: 'voting_for_projects_name',
        rawName: text('voting_for_projects_name'),
        start: json['voting_for_projects_start'] as String? ?? '',
        end: json['voting_for_projects_end'] as String? ?? '',
      ),
    );

    // Results verification phase
    phases.add(
      Phase(
        key: 'voting_results_verification_name',
        rawName: text('voting_results_verification_name'),
        start: json['voting_results_verification_start'] as String? ?? '',
        end: json['voting_results_verification_end'] as String? ?? '',
      ),
    );

    // Official results phase
    phases.add(
      Phase(
        key: 'voting_results_name',
        rawName: text('voting_results_name'),
        start: json['voting_results_verification_end'] as String? ?? '',
        end: '', // no end, will be treated as infinite
      ),
    );

    return BOHarmonogram(phases: phases);
  }
}

class Phase {
  final String key;
  final String name;
  final String start;
  final String end;
  Phase({required this.key, required String rawName, required this.start, required this.end})
    : name = cleanHtmlString(rawName);
}
