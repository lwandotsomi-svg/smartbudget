import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String formatDateWithMonth(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

String formatDateForDisplay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) {
    return 'Today';
  } else if (dateOnly == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
    return DateFormat('EEEE').format(date);
  } else {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

String formatCurrency(double amount) {
  return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
}

String formatTime(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}
