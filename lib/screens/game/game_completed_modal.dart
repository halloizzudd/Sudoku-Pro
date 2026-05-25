import 'package:flutter/material.dart';

// UC-13: Layar "Game Completed!" yang muncul setelah board penuh & valid.
class GameCompletedModal extends StatelessWidget {
  final String difficulty;
  final int level;
  final int elapsedSeconds;
  final int score;
  final bool isNewPersonalBest;
  final int previousBestSeconds; // 0 jika belum ada
  final int streakDays;

  final VoidCallback onPlayNext;
  final VoidCallback onReviewGrid;
  final VoidCallback onShare;

  const GameCompletedModal({
    super.key,
    required this.difficulty,
    required this.level,
    required this.elapsedSeconds,
    required this.score,
    required this.isNewPersonalBest,
    required this.previousBestSeconds,
    required this.streakDays,
    required this.onPlayNext,
    required this.onReviewGrid,
    required this.onShare,
  });

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0F0F1A);
    const Color cardColor = Color(0xFF1E1E2E);
    const Color accent = Color(0xFF5C4EE5);
    const Color gold = Color(0xFFFFB938);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6E5BFF), Color(0xFF5C4EE5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: accent, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Game Completed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$difficulty difficulty • Level $level',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Time + Score row
              Row(
                children: [
                  Expanded(
                    child: _statTile(
                      label: 'COMPLETION TIME',
                      value: _format(elapsedSeconds),
                      valueColor: Colors.white,
                      cardColor: cardColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statTile(
                      label: 'TOTAL SCORE',
                      value: score.toString(),
                      valueColor: gold,
                      cardColor: cardColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Personal best box (hanya kalau new best)
              if (isNewPersonalBest)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.6)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.emoji_events_outlined,
                                    color: Colors.green, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'NEW PERSONAL BEST',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              previousBestSeconds == 0
                                  ? 'Previous: —'
                                  : 'Previous: ${_format(previousBestSeconds)}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              'New: ${_format(elapsedSeconds)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.bar_chart, color: Colors.green),
                    ],
                  ),
                ),
              if (isNewPersonalBest) const SizedBox(height: 12),

              // Streak chip
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gold.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: gold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$streakDays DAY SOLVE STREAK',
                        style: const TextStyle(
                          color: gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Primary CTA
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onPlayNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'PLAY NEXT LEVEL',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReviewGrid,
                      icon: const Icon(Icons.grid_on, size: 16),
                      label: const Text('REVIEW GRID'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3A3A5A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('SHARE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3A3A5A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required Color valueColor,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
