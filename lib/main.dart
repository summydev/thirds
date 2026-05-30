import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/logs/presentation/screens/weekly_view_screen.dart';

void main() {
  // Wrapping the entire app in ProviderScope is required for Riverpod
  runApp(const ProviderScope(child: ThirdsApp()));
}

class ThirdsApp extends StatelessWidget {
  const ThirdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thirds',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const WeeklyViewScreen(),
    );
  }
}