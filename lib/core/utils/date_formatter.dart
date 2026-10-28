import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatEntryDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0 && now.day == dateTime.day) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != dateTime.day)) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, y • h:mm a').format(dateTime);
    }
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy • h:mm:ss a').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d').format(dateTime);
  }
}
