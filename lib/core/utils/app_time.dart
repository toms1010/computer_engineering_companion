/// Formats dates and relative times consistently.
///
/// The previous implementation called `DateTime.now()` inline from `build`,
/// which made output change on every rebuild and allocated a new string per
/// row. Callers now pass in a single "now" per build.
abstract final class AppTime {
  /// Compact relative label: `just now`, `12m ago`, `3h ago`, `5d ago`.
  static String relative(DateTime time, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(time);
    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// `12 Mar 2025`
  static String date(DateTime value) =>
      '${_months[value.month - 1]} ${value.day} ${value.year}';

  /// `12 Mar, 14:05`
  static String dateTime(DateTime value) =>
      '${_months[value.month - 1]} ${value.day}, '
      '${_two(value.hour)}:${_two(value.minute)}';

  /// `14:05`
  static String clock(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}';

  /// Spoken-friendly form for screen readers and relative labels.
  static String greeting([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  /// `1h 05m`, used for study-time totals.
  static String duration(int totalMinutes) {
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${_two(minutes)}m';
  }

  /// `2:05` style stopwatch readout for the quiz timer.
  static String stopwatch(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${_two(seconds)}';
  }

  /// Parses an ISO-8601 timestamp, returning null instead of throwing on
  /// malformed stored data. Bad data must not crash a list.
  static DateTime? tryParseIso(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
