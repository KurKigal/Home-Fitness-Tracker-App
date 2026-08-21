DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String dateKey(DateTime date) {
  final normalized = normalizeDate(date);

  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

DateTime dateFromKey(String value) {
  return DateTime.parse(value);
}

bool isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
