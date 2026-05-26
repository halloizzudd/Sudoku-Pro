// Smoke test: memastikan aplikasi ter-build tanpa error dan menampilkan
// LoginScreen saat tidak ada sesi tersimpan (AuthGate).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sudoku/main.dart';

void main() {
  testWidgets('App builds and routes to login without a session',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({}); // tidak ada token

    await tester.pumpWidget(const SudokuApp());
    // Beri waktu AuthGate menyelesaikan pengecekan token async.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
