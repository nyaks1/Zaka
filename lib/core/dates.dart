import 'package:intl/intl.dart';

/// Small, dependency-free date helpers. All comparisons are done on
/// date-only values so "today" means the same thing morning and night.
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime atNoon(DateTime value) =>
    DateTime(value.year, value.month, value.day, 12);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const List<String> weekdayShortNames = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String shortDate(DateTime value) => DateFormat('EEE d MMM').format(value);

String longDate(DateTime value) => DateFormat('EEE d MMM yyyy').format(value);

String timeOfDay(DateTime value) => DateFormat('HH:mm').format(value);

/// "Today", "Yesterday", otherwise "Mon 26 Oct".
String dayLabel(DateTime value, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final day = dateOnly(value);
  final difference = today.difference(day).inDays;
  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  if (difference == -1) return 'Tomorrow';
  return shortDate(day);
}

/// Weekday names for a set of ISO weekdays, collapsed where possible.
/// {1,2,3,4,5} -> "Mon–Fri"; {6,7} -> "Sat–Sun"; {1,3,5} -> "Mon, Wed, Fri".
String describeWeekdays(Set<int> weekdays) {
  if (weekdays.isEmpty) return 'No days';
  final sorted = weekdays.toList()..sort();
  if (sorted.length == 7) return 'Every day';
  if (sorted.length == 5 && sorted.every((day) => day >= 1 && day <= 5)) {
    return 'Mon–Fri';
  }
  if (sorted.length == 2 && sorted[0] == 6 && sorted[1] == 7) {
    return 'Sat–Sun';
  }
  return sorted
      .map((day) => weekdayShortNames[(day - 1).clamp(0, 6)])
      .join(', ');
}
