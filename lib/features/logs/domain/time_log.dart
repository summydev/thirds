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

  Duration get duration => endTime.difference(startTime);

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

  String get dayOfWeek {
    return DateFormat('EEEE').format(startTime); 
  }

  DateTime get weekStartDate {
    int daysToSubtract = startTime.weekday % 7;
    return DateTime(startTime.year, startTime.month, startTime.day)
        .subtract(Duration(days: daysToSubtract));
  }
}