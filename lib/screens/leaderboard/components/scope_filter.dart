import 'package:flutter/material.dart';
import '../../../services/leaderboard_service.dart';

// Dua baris filter: scope (Global/Friends) + period (Daily/Weekly/All Time).
class ScopeFilter extends StatelessWidget {
  final LeaderboardScope scope;
  final LeaderboardPeriod period;
  final ValueChanged<LeaderboardScope> onScopeChanged;
  final ValueChanged<LeaderboardPeriod> onPeriodChanged;

  const ScopeFilter({
    super.key,
    required this.scope,
    required this.period,
    required this.onScopeChanged,
    required this.onPeriodChanged,
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
        // Period pills
        Row(
          children: [
            _periodPill('DAILY', LeaderboardPeriod.daily),
            const SizedBox(width: 8),
            _periodPill('WEEKLY', LeaderboardPeriod.weekly),
            const SizedBox(width: 8),
            _periodPill('ALL TIME', LeaderboardPeriod.allTime),
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

  Widget _periodPill(String label, LeaderboardPeriod p) {
    final bool selected = period == p;
    return GestureDetector(
      onTap: () => onPeriodChanged(p),
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
