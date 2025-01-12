import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now().toUtc();
    final difference = now.difference(timestamp);
    final local = timestamp.toLocal();

    if (difference.inSeconds < 30) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (local.year == now.year) {
      return DateFormat('MMMM d').format(local);
    } else {
      return DateFormat('MMMM d, y').format(local);
    }
  }

  static String formatDetailedTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    return DateFormat('MMMM d, y • h:mm a').format(local);
  }

  static String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
} 