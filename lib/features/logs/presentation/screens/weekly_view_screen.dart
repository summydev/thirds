import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/logs_provider.dart';
import '../../domain/time_log.dart';
import 'manual_entry_screen.dart'; // Added this import to link the screens

// We use ConsumerWidget instead of StatelessWidget so we can listen to Riverpod
class WeeklyViewScreen extends ConsumerWidget {
  const WeeklyViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to the smartly grouped data map
    final weeklyLogs = ref.watch(currentWeekProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Thirds', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // 2. Build a list of days
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: weeklyLogs.keys.length,
        itemBuilder: (context, index) {
          String day = weeklyLogs.keys.elementAt(index);
          Map<String, List<TimeLog>> timeBlocks = weeklyLogs[day]!;
          
          // Calculate the total time logged for this specific day
          Duration dailyTotal = Duration.zero;
          for (var block in timeBlocks.values) {
            for (var log in block) {
              dailyTotal += log.duration;
            }
          }

          return _buildDayCard(day, timeBlocks, dailyTotal);
        },
      ),
      // 3. The '+' button to add new logs - UPDATED TO NAVIGATE
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          // Navigates to the input screen instead of showing a snackbar
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildDayCard(String day, Map<String, List<TimeLog>> blocks, Duration total) {
    // Format the daily total for the top right of the card
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
        // By default, let's keep Monday expanded if we want, or leave them all collapsed
        children: [
          _buildTimeBlock('MORNING', blocks['MORNING']!),
          _buildTimeBlock('AFTERNOON', blocks['AFTERNOON']!),
          _buildTimeBlock('EVENING', blocks['EVENING']!),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(String blockName, List<TimeLog> logs) {
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
          // If the list is empty, display "null" exactly like your notes
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text('null', style: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic)),
            )
          else
            // If there are logs, map through them and display the rows
            ...logs.map((log) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(log.activityName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(log.formattedDuration, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}