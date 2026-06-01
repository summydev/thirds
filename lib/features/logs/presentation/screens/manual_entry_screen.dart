import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/logs_provider.dart';
import '../../domain/time_log.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  final TimeLog? logToEdit;

  const ManualEntryScreen({super.key, this.logToEdit});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _activityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    if (widget.logToEdit != null) {
      _activityController.text = widget.logToEdit!.activityName;
      _selectedDate = widget.logToEdit!.startTime;
      _startTime = TimeOfDay.fromDateTime(widget.logToEdit!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.logToEdit!.endTime);
    }
  }

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

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

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart 
          ? (_startTime ?? TimeOfDay.now()) 
          : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  void _saveLog() {
    if (_activityController.text.isEmpty || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day, 
      _startTime!.hour, _startTime!.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day, 
      _endTime!.hour, _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time cannot be before start time!')),
      );
      return;
    }

    final newLog = TimeLog(
      id: widget.logToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      activityName: _activityController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
    );

    if (widget.logToEdit != null) {
      ref.read(logsProvider.notifier).editLog(newLog);
    } else {
      ref.read(logsProvider.notifier).addLog(newLog);
    }

    Navigator.pop(context);
  }

  void _deleteLog() {
    if (widget.logToEdit != null) {
      ref.read(logsProvider.notifier).deleteLog(widget.logToEdit!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.logToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Activity' : 'Add Activity', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteLog,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _activityController,
              decoration: InputDecoration(
                labelText: 'What did you do?',
                hintText: 'e.g., Real Analysis, Reading...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Time', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_startTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(isStart: true),
            ),
            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End Time', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_endTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time_filled),
              onTap: () => _pickTime(isStart: false),
            ),
            
            const Spacer(),

            ElevatedButton(
              onPressed: _saveLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isEditing ? 'Update Log' : 'Save Log', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}