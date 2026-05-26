import 'package:share_plus/share_plus.dart';

// UC-17: share hasil/ranking via share sheet OS. Semua call site lewat sini
// agar dependensi share_plus terisolasi di satu tempat.
class ShareService {
  static String _fmtTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Hasil game selesai.
  static Future<void> shareResult({
    required String difficulty,
    required int elapsedSeconds,
    required int score,
  }) {
    final text =
        'I just completed a $difficulty Sudoku puzzle in ${_fmtTime(elapsedSeconds)} '
        '($score pts) on Sudoku Pro! Can you beat my time?';
    return Share.share(text, subject: 'My Sudoku Pro result');
  }

  // Game over (kalah) — tetap bisa menantang teman.
  static Future<void> shareGameOver({
    required int elapsedSeconds,
    required int filledCells,
  }) {
    final text =
        'I hit 3 mistakes on Sudoku Pro after ${_fmtTime(elapsedSeconds)} '
        '($filledCells cells filled). Think you can do better?';
    return Share.share(text, subject: 'Sudoku Pro challenge');
  }

  // Ringkasan statistik dari Stats screen.
  static Future<void> shareStats({
    required int gamesWon,
    required int winRatePercent,
    required int bestTimeSeconds,
  }) {
    final best = bestTimeSeconds > 0 ? _fmtTime(bestTimeSeconds) : '--:--';
    final text =
        'My Sudoku Pro stats: $gamesWon games won, $winRatePercent% win rate, '
        'best time $best. Join me on Sudoku Pro!';
    return Share.share(text, subject: 'My Sudoku Pro stats');
  }
}
