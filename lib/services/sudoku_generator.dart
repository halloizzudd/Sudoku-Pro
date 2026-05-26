import 'dart:math';
import 'package:flutter/foundation.dart';

// UC-06 / FR-01: generator puzzle Sudoku dengan solusi unik per difficulty.
// Dijalankan via compute() agar tidak nge-freeze UI (anti-pattern #6 di spec).
class SudokuPuzzle {
  final List<int> puzzle; // 81 sel, 0 = kosong (clue awal)
  final List<int> solution; // 81 sel solusi penuh
  final String difficulty;

  const SudokuPuzzle({
    required this.puzzle,
    required this.solution,
    required this.difficulty,
  });
}

// Rentang jumlah clue per difficulty (UC-06 catatan implementasi).
const Map<String, List<int>> _clueRange = {
  'Easy': [36, 40],
  'Medium': [30, 35],
  'Hard': [25, 29],
  'Expert': [22, 24],
  'Master': [17, 21],
};

class SudokuGenerator {
  // API publik: generate di background isolate.
  static Future<SudokuPuzzle> generate(String difficulty) {
    return compute(_generatePuzzle, difficulty);
  }
}

// --- Top-level (wajib untuk compute/isolate) ---

SudokuPuzzle _generatePuzzle(String difficulty) {
  final rng = Random();
  final solution = List<int>.filled(81, 0);
  _fillBoard(solution, rng); // solusi penuh acak

  final puzzle = List<int>.of(solution);
  final range = _clueRange[difficulty] ?? const [30, 35];
  final targetClues = range[0] + rng.nextInt(range[1] - range[0] + 1);

  // Gali sel satu per satu (urutan acak), pertahankan solusi unik.
  final positions = List<int>.generate(81, (i) => i)..shuffle(rng);
  int clues = 81;
  for (final p in positions) {
    if (clues <= targetClues) break;
    final saved = puzzle[p];
    puzzle[p] = 0;
    if (_countSolutions(List<int>.of(puzzle), 2) != 1) {
      puzzle[p] = saved; // membuat ganda → kembalikan
    } else {
      clues--;
    }
  }

  return SudokuPuzzle(
      puzzle: puzzle, solution: solution, difficulty: difficulty);
}

// Isi board kosong dengan backtracking + kandidat teracak → solusi valid acak.
bool _fillBoard(List<int> b, Random rng) {
  final pos = b.indexOf(0);
  if (pos == -1) return true;
  final candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(rng);
  for (final n in candidates) {
    if (_isValid(b, pos, n)) {
      b[pos] = n;
      if (_fillBoard(b, rng)) return true;
      b[pos] = 0;
    }
  }
  return false;
}

// Hitung jumlah solusi (early-exit di [limit]) untuk cek keunikan.
int _countSolutions(List<int> b, int limit) {
  final pos = b.indexOf(0);
  if (pos == -1) return 1;
  int total = 0;
  for (int n = 1; n <= 9; n++) {
    if (_isValid(b, pos, n)) {
      b[pos] = n;
      total += _countSolutions(b, limit);
      b[pos] = 0;
      if (total >= limit) return total;
    }
  }
  return total;
}

bool _isValid(List<int> b, int pos, int n) {
  final row = pos ~/ 9;
  final col = pos % 9;
  final boxRow = (row ~/ 3) * 3;
  final boxCol = (col ~/ 3) * 3;
  for (int i = 0; i < 9; i++) {
    if (b[row * 9 + i] == n) return false; // baris
    if (b[i * 9 + col] == n) return false; // kolom
  }
  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < 3; c++) {
      if (b[(boxRow + r) * 9 + (boxCol + c)] == n) return false; // box
    }
  }
  return true;
}
