import 'package:intl/intl.dart';

class AppDateFormatter {
  static DateTime _parseDateOnly(String dateStr) {
    if (dateStr.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(dateStr)) {
      final parts = dateStr.substring(0, 10).split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }
    return DateTime.parse(dateStr).toLocal();
  }

  static String formatShort(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No due date';
    try {
      final date = _parseDateOnly(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(date.year, date.month, date.day);

      final diffDays = targetDate.difference(today).inDays;

      if (diffDays == 0) return 'Today';
      if (diffDays == 1) return 'Tomorrow';
      if (diffDays == -1) return 'Yesterday';
      if (diffDays < -1) return '${-diffDays}d overdue';

      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatFull(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = _parseDateOnly(dateStr);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatTimestamp(String? timestampStr) {
    if (timestampStr == null || timestampStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(timestampStr).toLocal();
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    } catch (_) {
      return timestampStr;
    }
  }

  static bool isOverdue(String? dateStr, String? status) {
    if (dateStr == null || status == 'DONE') return false;
    try {
      final date = _parseDateOnly(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return targetDate.isBefore(today);
    } catch (_) {
      return false;
    }
  }
}
