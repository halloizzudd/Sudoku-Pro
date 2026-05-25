import 'package:flutter/material.dart';
import 'screens/root_shell.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C4EE5),
          brightness: Brightness.dark,
        ),
      ),
      home: const RootShell(),
    );
  }
}
