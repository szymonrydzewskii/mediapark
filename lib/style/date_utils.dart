import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      final diff = DateTime.now().difference(dt);

      if (diff.inDays == 7) {
        return "tydzień temu";
      } else if (diff.inDays > 7) {
        return dt.day.toString().padLeft(2, '0') + '.' +
               dt.month.toString().padLeft(2, '0') + '.' +
               dt.year.toString();
      } else if (diff.inDays >= 1) {
        return "${diff.inDays} dni temu";
      } else if (diff.inHours >= 1) {
        return "${diff.inHours} godzin temu";
      }

      return "dzisiaj";
    } catch (_) {
      return datetime;
    }
  }

  static String formatDayTitle(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDay = DateTime(day.year, day.month, day.day);

    if (eventDay == today) {
      return 'Dzisiaj ${DateFormat('d.MM', 'pl_PL').format(day)}';
    } else if (eventDay == tomorrow) {
      return 'Jutro ${DateFormat('d.MM', 'pl_PL').format(day)}';
    } else {
      String formatted = DateFormat('EEEE d.MM', 'pl_PL').format(day);
      return formatted[0].toUpperCase() + formatted.substring(1);
    }
  }

  static String formatEventChip(DateTime start, bool allDay) {
    final dfTimeOnly = DateFormat('HH:mm');
    final dfDayShort = DateFormat('dd.MM.yy');

    DateTime norm(DateTime x) => DateTime(x.year, x.month, x.day);
    final today = norm(DateTime.now());
    final tomorrow = norm(DateTime.now().add(const Duration(days: 1)));
    final eventDay = norm(start);

    if (allDay) {
      return '${dfDayShort.format(start)} / Cały dzień';
    } else if (eventDay == today) {
      return 'Dzisiaj / ${dfTimeOnly.format(start)}';
    } else if (eventDay == tomorrow) {
      return 'Jutro / ${dfTimeOnly.format(start)}';
    } else {
      return '${dfDayShort.format(start)} / ${dfTimeOnly.format(start)}';
    }
  }

  static String formatMonthYear(DateTime date) {
    final formatted = DateFormat('LLLL yyyy', 'pl_PL').format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  static DateTime parseDate(String s) {
    return DateFormat("dd.MM.yyyy")
        .parse(s.replaceAll(RegExp(r"[^\d.]"), ""), true)
        .toLocal();
  }

  static String formatDateDdMmYyyy(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}