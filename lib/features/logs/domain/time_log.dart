import 'package:intl/intl.dart';

class TimeLog {
  final String id;
  final String activityName;
  final DateTime startTime;
  final DateTime endTime;

  TimeLog({
    required this.id,
    required this.activityName,
    required this.startTime,
    required this.endTime,
  });

  // 1. Calculates the exact time spent automatically
  Duration get duration => endTime.difference(startTime);

  // 2. Converts the duration into a clean, readable string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  // 3. The "Thirds" Engine: Automatically assigns MORNING, AFTERNOON, or EVENING
  String get timeOfDay {
    final hour = startTime.hour;
    if (hour >= 0 && hour < 12) {
      return 'MORNING';
    } else if (hour >= 12 && hour < 17) {
      return 'AFTERNOON';
    } else {
      return 'EVENING';
    }
  }

  // 4. Helper to get the name of the day (e.g., "Monday")
  String get dayOfWeek {
    return DateFormat('EEEE').format(startTime); 
  }

  // 5. The Week Identifier (Sunday Start)
  // Calculates the exact date of the Sunday that started this log's week
  DateTime get weekStartDate {
    // Dart's weekday: Monday=1 ... Sunday=7
    // Using modulo 7 turns Sunday into 0, Monday into 1, Tuesday into 2...
    int daysToSubtract = startTime.weekday % 7;
    
    // Subtract those days to find the Sunday of that week at midnight
    return DateTime(startTime.year, startTime.month, startTime.day)
        .subtract(Duration(days: daysToSubtract));
  }
}