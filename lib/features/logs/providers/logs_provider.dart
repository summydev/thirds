import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/time_log.dart';

// 1. The Notifier: This manages the actual list of logs and how to change them.
class LogsNotifier extends Notifier<List<TimeLog>> {
  @override
  List<TimeLog> build() {
    return [
      // --- SUNDAY (May 24) ---
      TimeLog(
        id: 'sun_1',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 24, 11, 30),
        endTime: DateTime(2026, 5, 24, 12, 00),
      ),
      TimeLog(
        id: 'sun_2',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 24, 15, 21), // 3:21 PM
        endTime: DateTime(2026, 5, 24, 16, 15), // 4:15 PM
      ),
      TimeLog(
        id: 'sun_3',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 24, 17, 50), // 5:50 PM - App will auto-sort to EVENING
        endTime: DateTime(2026, 5, 24, 18, 50), // 6:50 PM
      ),

      // --- MONDAY (May 25) ---
      TimeLog(
        id: 'mon_1',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 25, 6, 11),
        endTime: DateTime(2026, 5, 25, 7, 20),
      ),

      // --- THURSDAY (May 28) ---
      TimeLog(
        id: 'thu_1',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 28, 15, 20), // 3:20 PM
        endTime: DateTime(2026, 5, 28, 16, 00), // 4:00 PM
      ),

      // --- SATURDAY (May 30 - Today!) ---
      TimeLog(
        id: 'sat_1',
        activityName: 'Reading', // Update this if it was also Real Analysis!
        startTime: DateTime(2026, 5, 30, 18, 11), // 6:11 PM
        endTime: DateTime(2026, 5, 30, 18, 30), // 6:30 PM
      ),
    ];
  }

  // The function your "Save" button will call
  void addLog(TimeLog log) {
    state = [...state, log];
  }

  // You will definitely need this when you accidentally typo a time!
  void deleteLog(String id) {
    state = state.where((log) => log.id != id).toList();
  }
}

// 2. The Main Provider: Your UI will watch this to see the raw list of logs.
final logsProvider = NotifierProvider<LogsNotifier, List<TimeLog>>(() {
  return LogsNotifier();
});

// 3. The "Smart" Provider: This formats the data perfectly for your "Thirds" layout.
// Your Weekly View UI will just read this map and easily build the cards.
final weeklyGroupedLogsProvider = Provider<Map<String, Map<String, List<TimeLog>>>>((ref) {
  // Watch the raw logs. Every time you add a log, this entire map automatically recalculates!
  final allLogs = ref.watch(logsProvider);
  
  // Set up the empty template for the week
  Map<String, Map<String, List<TimeLog>>> grouped = {
    'Monday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Tuesday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Wednesday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Thursday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Friday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Saturday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Sunday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
  };

  // Drop each log into its exact slot
  for (final log in allLogs) {
    final day = log.dayOfWeek;
    final time = log.timeOfDay;
    
    // Safety check, then place the log in the correct nested list
    if (grouped.containsKey(day) && grouped[day]!.containsKey(time)) {
      grouped[day]![time]!.add(log);
    }
  }

  return grouped;
});