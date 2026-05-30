import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/logs_provider.dart';
import '../../domain/time_log.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _activityController = TextEditingController();
  
  // Default to today, but allow changing it for past logs
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  // --- HELPER: Pick a Date ---
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- HELPER: Pick a Time ---
  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // --- HELPER: Save to Riverpod ---
  void _saveLog() {
    if (_activityController.text.isEmpty || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
      return;
    }

    // Merge the chosen date and times into full DateTime objects
    final startDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day, 
      _startTime!.hour, _startTime!.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day, 
      _endTime!.hour, _endTime!.minute,
    );

    // Create the new log
    final newLog = TimeLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityName: _activityController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
    );

    // Tell Riverpod to add it!
    ref.read(logsProvider.notifier).addLog(newLog);

    // Go back to the dashboard
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Activity', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Activity Name
            TextField(
              controller: _activityController,
              decoration: InputDecoration(
                labelText: 'What did you do?',
                hintText: 'e.g., Real Analysis, Reading...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Date Picker (Defaults to today)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const Divider(),

            // 3. Start Time Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Time', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_startTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(isStart: true),
            ),
            const Divider(),

            // 4. End Time Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End Time', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_endTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time_filled),
              onTap: () => _pickTime(isStart: false),
            ),
            
            const Spacer(),

            // 5. Save Button
            ElevatedButton(
              onPressed: _saveLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}