import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class WydarzenieListItem {
  final int id;
  final String title;
  final String? intro;
  final bool allDay;
  final DateTime start;
  final DateTime? end;
  final String? mainPhoto;

  const WydarzenieListItem({
    required this.id,
    required this.title,
    required this.allDay,
    required this.start,
    this.end,
    this.intro,
    this.mainPhoto,
  });

  factory WydarzenieListItem.fromJson(Map<String, dynamic> j) {
    final bool isAllDay = (j['is_event_all_day'] ?? 0) == 1;

    DateTime _combine(String date, String? time) {
      final d = DateFormat('yyyy-MM-dd').parse(date, true).toLocal();
      if (time == null || time.isEmpty) return DateTime(d.year, d.month, d.day);
      final t = DateFormat('HH:mm').parse(time, true).toLocal();
      return DateTime(d.year, d.month, d.day, t.hour, t.minute);
    }

    DateTime start = _combine(
      j['event_start_date'] ?? '',
      j['event_start_time'],
    );
    DateTime? end;
    if ((j['event_end_date'] ?? '').toString().isNotEmpty) {
      end = _combine(j['event_end_date'], j['event_end_time']);
      // sanity fix — niektóre testowe dane mają koniec < start
      if (end.isBefore(start)) end = start;
    }

    return WydarzenieListItem(
      id:
          (j['id_event'] ?? 0) is String
              ? int.tryParse(j['id_event']) ?? 0
              : (j['id_event'] ?? 0),
      title: (j['title'] ?? '').toString().trim(),
      intro:
          (j['intro'] ?? '').toString().trim().isEmpty
              ? null
              : j['intro'].toString().trim(),
      allDay: isAllDay,
      start: start,
      end: end,
      mainPhoto:
          (j['main_photo'] ?? '').toString().trim().isEmpty
              ? null
              : j['main_photo'].toString().trim(),
    );
  }
}

@immutable
class WydarzenieDetails {
  final int id;
  final String title;
  final String contentHtml;
  final bool allDay;
  final DateTime start;
  final DateTime? end;
  final String? mainPhoto; // 🔹 DODANE POLE

  const WydarzenieDetails({
    required this.id,
    required this.title,
    required this.contentHtml,
    required this.allDay,
    required this.start,
    this.end,
    this.mainPhoto, // 🔹 DODANE POLE
  });

  factory WydarzenieDetails.fromJson(Map<String, dynamic> j) {
    final bool isAllDay = (j['is_event_all_day'] ?? 0) == 1;

    DateTime _combine(String date, String? time) {
      final d = DateFormat('yyyy-MM-dd').parse(date, true).toLocal();
      if (time == null || time.isEmpty) return DateTime(d.year, d.month, d.day);
      final t = DateFormat('HH:mm').parse(time, true).toLocal();
      return DateTime(d.year, d.month, d.day, t.hour, t.minute);
    }

    DateTime start = _combine(
      j['event_start_date'] ?? '',
      j['event_start_time'],
    );
    DateTime? end;
    if ((j['event_end_date'] ?? '').toString().isNotEmpty) {
      end = _combine(j['event_end_date'], j['event_end_time']);
      if (end.isBefore(start)) end = start;
    }

    return WydarzenieDetails(
      id:
          (j['id_event'] ?? 0) is String
              ? int.tryParse(j['id_event']) ?? 0
              : (j['id_event'] ?? 0),
      title: (j['title'] ?? '').toString().trim(),
      contentHtml: (j['content'] ?? '').toString(),
      allDay: isAllDay,
      start: start,
      end: end,
      mainPhoto:
          (j['main_photo'] ?? '').toString().trim().isEmpty
              ? null
              : j['main_photo'].toString().trim(), // 🔹 DODANE POLE
    );
  }
}
