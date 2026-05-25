import 'package:flutter/material.dart';

// UC-14: Modal yang muncul ketika mistakes = 3/3.
class GameOverModal extends StatelessWidget {
  final int elapsedSeconds;
  final int filledCells; // jumlah sel non-clue yang sudah terisi (benar/salah)

  final VoidCallback onTryAgain; // puzzle yang sama
  final VoidCallback onNewPuzzle; // UC-06
  final VoidCallback onBackHome;

  const GameOverModal({
    super.key,
    required this.elapsedSeconds,
    required this.filledCells,
    required this.onTryAgain,
    required this.onNewPuzzle,
    required this.onBackHome,
  });

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF1E1E2E);
    const Color danger = Color(0xFFE53935);

    return Dialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: danger.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: danger, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'You reached 3 mistakes.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _miniStat('TIME', _format(elapsedSeconds)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniStat('FILLED', '$filledCells'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C4EE5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'TRY AGAIN',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onNewPuzzle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF3A3A5A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('NEW PUZZLE'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onBackHome,
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
