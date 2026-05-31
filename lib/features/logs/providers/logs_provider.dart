import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/time_log.dart';

// 1. The Notifier: This manages the actual list of ALL logs (past and present).
class LogsNotifier extends Notifier<List<TimeLog>> {
  @override
  List<TimeLog> build() {
    return [
      // --- SUNDAY (May 24) - History ---
      TimeLog(
        id: 'sun_1',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 24, 11, 30),
        endTime: DateTime(2026, 5, 24, 12, 00),
      ),
      TimeLog(
        id: 'sun_2',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 24, 15, 21), 
        endTime: DateTime(2026, 5, 24, 16, 15), 
      ),
      TimeLog(
        id: 'sun_3',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 24, 17, 50), 
        endTime: DateTime(2026, 5, 24, 18, 50), 
      ),

      // --- MONDAY (May 25) - History ---
      TimeLog(
        id: 'mon_1',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 25, 6, 11),
        endTime: DateTime(2026, 5, 25, 7, 20),
      ),

      // --- THURSDAY (May 28) - History ---
      TimeLog(
        id: 'thu_1',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 28, 15, 20), 
        endTime: DateTime(2026, 5, 28, 16, 00), 
      ),

      // --- SATURDAY (May 30) - History ---
      TimeLog(
        id: 'sat_1',
        activityName: 'Reading', 
        startTime: DateTime(2026, 5, 30, 18, 11), 
        endTime: DateTime(2026, 5, 30, 18, 30), 
      ),
    ];
  }

  void addLog(TimeLog log) {
    state = [...state, log];
  }

  void deleteLog(String id) {
    state = state.where((log) => log.id != id).toList();
  }
}

// 2. The Main Provider: Holds everything.
final logsProvider = NotifierProvider<LogsNotifier, List<TimeLog>>(() {
  return LogsNotifier();
});

// 3. The "Current Week" Provider: Filters and sorts the data for your Dashboard.
final currentWeekProvider = Provider<Map<String, Map<String, List<TimeLog>>>>((ref) {
  final allLogs = ref.watch(logsProvider);
  
  // Find out what the date was for THIS week's Sunday at midnight
  final now = DateTime.now();
  final int daysToSubtract = now.weekday % 7;
  final currentSunday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));

  // 1. FILTER: Only keep logs that belong to this week
  final thisWeeksLogs = allLogs.where((log) => log.weekStartDate == currentSunday).toList();

  // 2. REORDER: Set up the template starting from Sunday instead of Monday
  Map<String, Map<String, List<TimeLog>>> grouped = {
    'Sunday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Monday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Tuesday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Wednesday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Thursday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Friday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Saturday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
  };

  // 3. DROP IN DATA
  for (final log in thisWeeksLogs) {
    final day = log.dayOfWeek;
    final time = log.timeOfDay;
    
    if (grouped.containsKey(day) && grouped[day]!.containsKey(time)) {
      grouped[day]![time]!.add(log);
    }
  }

  return grouped;
});