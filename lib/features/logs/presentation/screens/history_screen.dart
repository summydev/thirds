import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/logs_provider.dart';
import '../../domain/time_log.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyLogs = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: historyLogs.isEmpty
          ? const Center(
              child: Text('No past weeks logged yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyLogs.keys.length,
              itemBuilder: (context, index) {
                DateTime weekStart = historyLogs.keys.elementAt(index);
                List<TimeLog> logsForThisWeek = historyLogs[weekStart]!;

                DateTime weekEnd = weekStart.add(const Duration(days: 6));
                
                String dateRange = '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}';

                Duration weeklyTotal = Duration.zero;
                for (var log in logsForThisWeek) {
                  weeklyTotal += log.duration;
                }
                
                final hours = weeklyTotal.inHours;
                final minutes = weeklyTotal.inMinutes.remainder(60);
                final totalText = '${hours}h ${minutes}m';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    title: Text(dateRange, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${logsForThisWeek.length} activities logged', style: const TextStyle(color: Colors.grey)),
                    ),
                    trailing: Text(totalText, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 16)),
                  ),
                );
              },
            ),
    );
  }
} 