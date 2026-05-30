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

  // 1. The Math: Calculates the exact time spent automatically
  Duration get duration => endTime.difference(startTime);

  // 2. The Formatter: Converts the duration into a clean, readable string 
  // e.g., if you log 69 minutes of Real Analysis, it outputs "1h 9m"
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

  // 4. The Day Grouper: Helper to get the name of the day for your Weekly View
  // e.g., Returns "Monday" so your UI knows exactly which card to drop this into
  String get dayOfWeek {
    return DateFormat('EEEE').format(startTime); 
  }

  // 5. The Week Identifier: Helper to group logs by the exact week of the year
  // This ensures logs from this week don't mix with logs from last week
  int get weekOfYear {
    // A simple calculation to find the week number
    int dayOfYear = int.parse(DateFormat('D').format(startTime));
    return ((dayOfYear - startTime.weekday + 10) / 7).floor();
  }
}