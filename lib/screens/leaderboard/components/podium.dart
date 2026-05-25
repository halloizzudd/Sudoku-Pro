import 'package:flutter/material.dart';
import '../../../models/leaderboard_entry.dart';

// UC-15 Step 3: Top 3 podium. Rank 1 di tengah (lebih tinggi & dengan crown),
// rank 2 di kiri, rank 3 di kanan.
class Podium extends StatelessWidget {
  final List<LeaderboardEntry> top3;
  const Podium({super.key, required this.top3});

  static String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  LeaderboardEntry? _byRank(int rank) =>
      top3.where((e) => e.rank == rank).cast<LeaderboardEntry?>().firstWhere((_) => true, orElse: () => null);

  @override
  Widget build(BuildContext context) {
    final first = _byRank(1);
    final second = _byRank(2);
    final third = _byRank(3);

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Card center (rank 1) lebih besar dan di tengah
          if (first != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: _podiumCard(
                entry: first,
                accent: const Color(0xFFFFB938),
                width: 130,
                height: 140,
                showCrown: true,
              ),
            ),
          if (second != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: _podiumCard(
                  entry: second,
                  accent: Colors.grey,
                  width: 110,
                  height: 110,
                ),
              ),
            ),
          if (third != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: _podiumCard(
                  entry: third,
                  accent: const Color(0xFFCD7F32),
                  width: 110,
                  height: 110,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _podiumCard({
    required LeaderboardEntry entry,
    required Color accent,
    required double width,
    required double height,
    bool showCrown = false,
  }) {
    return SizedBox(
      width: width,
      height: height + (showCrown ? 60 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showCrown)
            const Icon(Icons.emoji_events, color: Color(0xFFFFB938), size: 22),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A4A),
              border: Border.all(color: accent, width: 2),
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width,
            height: height - 56,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: showCrown ? const Color(0xFF5C4EE5) : const Color(0xFF1E1E2E),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt(entry.timeSeconds),
                  style: TextStyle(
                    color: showCrown ? const Color(0xFFFFB938) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
