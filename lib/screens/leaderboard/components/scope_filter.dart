import 'package:flutter/material.dart';
import '../leaderboard_screen.dart';

// Dua baris filter: scope (Global/Friends) + range (Daily/Weekly/All Time).
class ScopeFilter extends StatelessWidget {
  final LeaderboardScope scope;
  final LeaderboardRange range;
  final ValueChanged<LeaderboardScope> onScopeChanged;
  final ValueChanged<LeaderboardRange> onRangeChanged;

  const ScopeFilter({
    super.key,
    required this.scope,
    required this.range,
    required this.onScopeChanged,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Global / Friends segmented
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _segment(
                label: 'GLOBAL',
                selected: scope == LeaderboardScope.global,
                onTap: () => onScopeChanged(LeaderboardScope.global),
              ),
              _segment(
                label: 'FRIENDS',
                selected: scope == LeaderboardScope.friends,
                onTap: () => onScopeChanged(LeaderboardScope.friends),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Range pills
        Row(
          children: [
            _rangePill('DAILY', LeaderboardRange.daily),
            const SizedBox(width: 8),
            _rangePill('WEEKLY', LeaderboardRange.weekly),
            const SizedBox(width: 8),
            _rangePill('ALL TIME', LeaderboardRange.allTime),
          ],
        ),
      ],
    );
  }

  Widget _segment({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF5C4EE5) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rangePill(String label, LeaderboardRange r) {
    final bool selected = range == r;
    return GestureDetector(
      onTap: () => onRangeChanged(r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5C4EE5) : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
