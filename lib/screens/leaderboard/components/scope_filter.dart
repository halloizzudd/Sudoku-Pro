import 'package:flutter/material.dart';
import '../../../services/leaderboard_service.dart';
import '../../../theme/app_colors.dart';

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
    final c = context.colors;
    return Column(
      children: [
        // Global / Friends segmented
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _segment(
                c: c,
                label: 'GLOBAL',
                selected: scope == LeaderboardScope.global,
                onTap: () => onScopeChanged(LeaderboardScope.global),
              ),
              _segment(
                c: c,
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
            _periodPill(c, 'DAILY', LeaderboardPeriod.daily),
            const SizedBox(width: 8),
            _periodPill(c, 'WEEKLY', LeaderboardPeriod.weekly),
            const SizedBox(width: 8),
            _periodPill(c, 'ALL TIME', LeaderboardPeriod.allTime),
          ],
        ),
      ],
    );
  }

  Widget _segment({
    required AppColors c,
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
            color: selected ? c.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : c.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _periodPill(AppColors c, String label, LeaderboardPeriod p) {
    final bool selected = period == p;
    return GestureDetector(
      onTap: () => onPeriodChanged(p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : c.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
