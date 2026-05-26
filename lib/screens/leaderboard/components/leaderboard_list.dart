import 'package:flutter/material.dart';
import '../../../models/leaderboard_entry.dart';
import '../../../theme/app_colors.dart';

// UC-15 Step 4: list rank 4 ke bawah dengan rank, avatar, username, tag, waktu.
class LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final VoidCallback? onLoadMore;

  const LeaderboardList({
    super.key,
    required this.entries,
    this.onLoadMore,
  });

  static String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 80) {
          onLoadMore?.call();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = entries[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${e.rank}',
                    style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: c.surface2,
                  child: Icon(Icons.person, color: c.textPrimary, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          e.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: c.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      if (e.isPro) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.primary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('PRO',
                              style: TextStyle(color: c.primary, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  _fmt(e.timeSeconds),
                  style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
