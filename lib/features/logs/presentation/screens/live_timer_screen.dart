import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/logs_provider.dart';
import '../../domain/time_log.dart';

class LiveTimerScreen extends ConsumerStatefulWidget {
  const LiveTimerScreen({super.key});

  @override
  ConsumerState<LiveTimerScreen> createState() => _LiveTimerScreenState();
}

// The 'WidgetsBindingObserver' is the secret sauce that knows when you leave the app
class _LiveTimerScreenState extends ConsumerState<LiveTimerScreen> with WidgetsBindingObserver {
  final _activityController = TextEditingController(text: 'Reading'); // Default to Reading
  
  DateTime? _startTime;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Start watching the app's lifecycle as soon as this screen opens
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Stop watching when we close the screen
    WidgetsBinding.instance.removeObserver(this);
    
    // If the user hits the back button while the timer is running, save the log!
    if (_isRunning) {
      _stopAndSaveLog();
    }
    
    _ticker?.cancel();
    _activityController.dispose();
    super.dispose();
  }

  // THIS is where the magic happens. It fires when the app goes to the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isRunning) {
        _stopAndSaveLog();
        // We can't show a snackbar easily while the app is in the background, 
        // but the data will be safely saved!
      }
    }
  }

  void _startTimer() {
    if (_activityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('What are you reading?')),
      );
      return;
    }

    // Hide keyboard so it looks clean
    FocusScope.of(context).unfocus();

    setState(() {
      _startTime = DateTime.now();
      _isRunning = true;
      _elapsed = Duration.zero;
    });

    // Update the UI every single second
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  void _stopAndSaveLog() {
    if (!_isRunning || _startTime == null) return;

    _ticker?.cancel();
    final endTime = DateTime.now();

    // Create the log and save it to Riverpod
    final newLog = TimeLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityName: _activityController.text.trim(),
      startTime: _startTime!,
      endTime: endTime,
    );

    ref.read(logsProvider.notifier).addLog(newLog);

    setState(() {
      _isRunning = false;
    });

    // Close the timer screen and go back to the dashboard
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // Helper to format the stopwatch text (e.g., "01:23:05")
  String get _formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_elapsed.inHours);
    final minutes = twoDigits(_elapsed.inMinutes.remainder(60));
    final seconds = twoDigits(_elapsed.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Live Session', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The Subject Input
            TextField(
              controller: _activityController,
              enabled: !_isRunning, // Lock the text field once they start!
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'What are you reading?',
              ),
            ),
            const SizedBox(height: 40),

            // The Giant Timer
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 72, 
                fontWeight: FontWeight.w200, // Thin, sleek font
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 60),

            // The Start / Stop Button
            SizedBox(
              height: 80,
              width: 80,
              child: FloatingActionButton(
                backgroundColor: _isRunning ? Colors.red : Colors.black,
                elevation: 0,
                shape: const CircleBorder(),
                onPressed: _isRunning ? _stopAndSaveLog : _startTimer,
                child: Icon(
                  _isRunning ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Helper text
            Text(
              _isRunning 
                  ? "Focus. If you leave this screen, the session ends." 
                  : "Tap to start your session.",
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}