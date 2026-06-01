import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/time_log.dart';

class LogsNotifier extends Notifier<List<TimeLog>> {
  @override
  List<TimeLog> build() {
    return [
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
      TimeLog(
        id: 'mon_1',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 25, 6, 11),
        endTime: DateTime(2026, 5, 25, 7, 20),
      ),
      TimeLog(
        id: 'thu_1',
        activityName: 'Real Analysis',
        startTime: DateTime(2026, 5, 28, 15, 20), 
        endTime: DateTime(2026, 5, 28, 16, 00), 
      ),
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

  void editLog(TimeLog updatedLog) {
    state = [
      for (final log in state)
        if (log.id == updatedLog.id) updatedLog else log
    ];
  }

  void deleteLog(String id) {
    state = state.where((log) => log.id != id).toList();
  }
}

final logsProvider = NotifierProvider<LogsNotifier, List<TimeLog>>(() {
  return LogsNotifier();
});

final currentWeekProvider = Provider<Map<String, Map<String, List<TimeLog>>>>((ref) {
  final allLogs = ref.watch(logsProvider);
  
  final now = DateTime.now();
  final int daysToSubtract = now.weekday % 7;
  final currentSunday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));

  final thisWeeksLogs = allLogs.where((log) => log.weekStartDate == currentSunday).toList();

  Map<String, Map<String, List<TimeLog>>> grouped = {
    'Sunday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Monday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Tuesday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Wednesday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Thursday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Friday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
    'Saturday': {'MORNING': [], 'AFTERNOON': [], 'EVENING': []},
  };

  for (final log in thisWeeksLogs) {
    final day = log.dayOfWeek;
    final time = log.timeOfDay;
    
    if (grouped.containsKey(day) && grouped[day]!.containsKey(time)) {
      grouped[day]![time]!.add(log);
    }
  }

  return grouped;
});

final historyProvider = Provider<Map<DateTime, List<TimeLog>>>((ref) {
  final allLogs = ref.watch(logsProvider);
  
  final now = DateTime.now();
  final int daysToSubtract = now.weekday % 7;
  final currentSunday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));

  final pastLogs = allLogs.where((log) => log.weekStartDate.isBefore(currentSunday)).toList();
  pastLogs.sort((a, b) => b.startTime.compareTo(a.startTime));

  Map<DateTime, List<TimeLog>> groupedHistory = {};
  for (var log in pastLogs) {
    if (!groupedHistory.containsKey(log.weekStartDate)) {
      groupedHistory[log.weekStartDate] = [];
    }
    groupedHistory[log.weekStartDate]!.add(log);
  }

  return groupedHistory;
});