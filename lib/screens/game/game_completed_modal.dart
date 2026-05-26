import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Konten atas dapat di-scroll agar tidak overflow di layar pendek.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero card (gradient brand, teks putih di kedua mode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 16),
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
                              child:
                                  Icon(Icons.check, color: c.primary, size: 32),
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
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time + Score row
                      Row(
                        children: [
                          Expanded(
                            child: _statTile(c,
                                label: 'COMPLETION TIME',
                                value: _format(elapsedSeconds),
                                valueColor: c.textPrimary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statTile(c,
                                label: 'TOTAL SCORE',
                                value: score.toString(),
                                valueColor: c.accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Personal best box (hanya kalau new best)
                      if (isNewPersonalBest)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: c.success.withOpacity(0.6)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.emoji_events_outlined,
                                            color: c.success, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'NEW PERSONAL BEST',
                                          style: TextStyle(
                                            color: c.success,
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
                                      style: TextStyle(
                                          color: c.textSecondary, fontSize: 12),
                                    ),
                                    Text(
                                      'New: ${_format(elapsedSeconds)}',
                                      style: TextStyle(
                                        color: c.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.bar_chart, color: c.success),
                            ],
                          ),
                        ),
                      if (isNewPersonalBest) const SizedBox(height: 12),

                      // Streak chip
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: c.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: c.accent.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department,
                                  color: c.accent, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '$streakDays DAY SOLVE STREAK',
                                style: TextStyle(
                                  color: c.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Primary CTA
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onPlayNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                        foregroundColor: c.textPrimary,
                        side: BorderSide(color: c.gridLine),
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
                        foregroundColor: c.textPrimary,
                        side: BorderSide(color: c.gridLine),
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

  Widget _statTile(
    AppColors c, {
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
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
