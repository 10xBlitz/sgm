import 'package:intl/intl.dart';

/// Extension methods for DateTime objects
extension DateExtension on DateTime {
  /// Converts the DateTime to UTC timezone
  DateTime toUtc() {
    return isUtc
        ? this
        : DateTime.utc(
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        );
  }

  /// Converts the DateTime to local timezone
  DateTime toLocal() {
    return isUtc
        ? DateTime(
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        )
        : this;
  }

  /// Formats the DateTime to "Month DD, YYYY (HH:MM)" format with military time
  String formatToMilitaryString() {
    final DateFormat formatter = DateFormat('MMMM dd, yyyy (HH:mm)');
    return formatter.format(this);
  }
}
