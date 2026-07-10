import 'package:intl/intl.dart';

final _dateTime = DateFormat('MMM d, yyyy HH:mm');
final _time = DateFormat('HH:mm');

String formatDateTime(DateTime? value) =>
    value == null ? 'Not set' : _dateTime.format(value.toLocal());

String formatTimeRange(DateTime? start, DateTime? end) {
  if (start == null || end == null) return 'Time not set';
  return '${_time.format(start.toLocal())} - ${_time.format(end.toLocal())}';
}

DateTime? parseDate(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());
