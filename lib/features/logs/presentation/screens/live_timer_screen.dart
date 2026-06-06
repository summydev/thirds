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

class _LiveTimerScreenState extends ConsumerState<LiveTimerScreen> with WidgetsBindingObserver {
  final _activityController = TextEditingController(text: 'Reading'); // Default text
  
  DateTime? _startTime;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Start watching the app's lifecycle
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

  // Fires when the app is minimized or the user switches apps
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isRunning) {
        _stopAndSaveLog();
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

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _startTime = DateTime.now();
      _isRunning = true;
      _elapsed = Duration.zero;
    });

    // Update the UI every second
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

    if (mounted) {
      Navigator.pop(context);
    }
  }

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
            TextField(
              controller: _activityController,
              enabled: !_isRunning,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'What are you reading?',
              ),
            ),
            const SizedBox(height: 40),

            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 72, 
                fontWeight: FontWeight.w200, 
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 60),

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
            
            Text(
              _isRunning 
                  ? "Focus. If you leave this app, the session ends." 
                  : "Tap to start your session.",
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}