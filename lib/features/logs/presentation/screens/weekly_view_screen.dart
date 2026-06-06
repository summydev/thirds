import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/logs_provider.dart';
import '../../domain/time_log.dart';
import 'manual_entry_screen.dart';
import 'history_screen.dart';
import 'live_timer_screen.dart'; // We added this import!

class WeeklyViewScreen extends ConsumerWidget {
  const WeeklyViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyLogs = ref.watch(currentWeekProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thirds', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: weeklyLogs.keys.length,
        itemBuilder: (context, index) {
          String day = weeklyLogs.keys.elementAt(index);
          Map<String, List<TimeLog>> timeBlocks = weeklyLogs[day]!;
          
          Duration dailyTotal = Duration.zero;
          for (var block in timeBlocks.values) {
            for (var log in block) {
              dailyTotal += log.duration;
            }
          }

          return _buildDayCard(context, day, timeBlocks, dailyTotal);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          // This is the new Bottom Sheet Menu
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.timer, color: Colors.black),
                    title: const Text('Start Live Session', style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveTimerScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_calendar, color: Colors.black),
                    title: const Text('Log Manually', style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ManualEntryScreen()));
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, String day, Map<String, List<TimeLog>> blocks, Duration total) {
    final hours = total.inHours;
    final minutes = total.inMinutes.remainder(60);
    final totalText = total == Duration.zero ? '0h 0m' : '${hours}h ${minutes}m';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: Text(
          totalText, 
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey, fontSize: 14)
        ),
        children: [
          _buildTimeBlock(context, 'MORNING', blocks['MORNING']!),
          _buildTimeBlock(context, 'AFTERNOON', blocks['AFTERNOON']!),
          _buildTimeBlock(context, 'EVENING', blocks['EVENING']!),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(BuildContext context, String blockName, List<TimeLog> logs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blockName, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)
          ),
          const SizedBox(height: 6),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text('null', style: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic)),
            )
          else
            ...logs.map((log) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManualEntryScreen(logToEdit: log),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(log.activityName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        Text(log.formattedDuration, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit_note, size: 18, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }
}