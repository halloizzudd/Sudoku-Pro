import 'package:flutter/material.dart';
import '../../models/player_stats.dart';
import '../../models/recent_game.dart';
import '../../services/local_storage_service.dart';
import '../../services/share_service.dart';
import '../../theme/app_colors.dart';
import '../notifications_screen.dart';

// UC-18: Statistik pribadi. Grid 2×3 + list "Recent Games".
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _indigo = Color(0xFF7C6CF5);

  late AppColors c;
  PlayerStats _stats = const PlayerStats();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Catatan UC-18: refresh tiap masuk Stats screen.
  Future<void> _load() async {
    final s = await LocalStorageService.loadStats();
    if (!mounted) return;
    setState(() {
      _stats = s;
      _loading = false;
    });
  }

  int _bestTimeOverall() {
    int best = 0;
    for (final v in _stats.bestTimeByDifficulty.values) {
      if (v > 0 && (best == 0 || v < best)) best = v;
    }
    return best;
  }

  static String _fmtTime(int s) {
    if (s <= 0) return '--:--';
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        title: Text('SUDOKU PRO',
            style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: c.textPrimary),
            onPressed: _loading
                ? null
                : () => ShareService.shareStats(
                      gamesWon: _stats.gamesWon,
                      winRatePercent: (_stats.winRate * 100).round(),
                      bestTimeSeconds: _bestTimeOverall(),
                    ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: c.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: _amber,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text('YOUR STATISTICS',
                      style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('All-time performance',
                      style: TextStyle(color: c.textSecondary, fontSize: 14)),
                  const SizedBox(height: 20),
                  _grid(),
                  const SizedBox(height: 28),
                  Text('RECENT GAMES',
                      style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  for (final g in _recentGames()) _recentTile(g),
                ],
              ),
            ),
    );
  }

  Widget _grid() {
    final winRate = (_stats.winRate * 100).round();
    final cells = <Widget>[
      _statCard('GAMES WON', '${_stats.gamesWon}'),
      _statCard('WIN RATE', '$winRate%', valueColor: _amber),
      _statCard('BEST TIME', _fmtTime(_bestTimeOverall()), valueColor: _indigo),
      _statCard('CURRENT STREAK', '${_stats.currentStreak}',
          trailingEmoji: _stats.currentStreak > 0 ? '🔥' : null),
      _statCard('LONGEST STREAK', '${_stats.longestStreak}',
          trailingEmoji: _stats.longestStreak > 0 ? '🔥' : null),
      _statCard('TOTAL GAMES', '${_stats.gamesPlayed}'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cardW = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final w in cells) SizedBox(width: cardW, child: w),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value,
      {Color? valueColor, String? trailingEmoji}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      color: valueColor ?? c.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              if (trailingEmoji != null) ...[
                const SizedBox(width: 6),
                Text(trailingEmoji, style: const TextStyle(fontSize: 22)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentTile(RecentGame g) {
    final dotColor = g.isCompleted ? _amber : const Color(0xFFE57373);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${g.difficulty} • Level ${g.level}',
                    style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_fmtPlayedAt(g.playedAt),
                    style: TextStyle(color: c.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Text(_fmtTime(g.durationSeconds ?? 0),
              style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${_fmtPoints(g.points)} pts',
                    style: TextStyle(color: c.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtPoints(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String _fmtPlayedAt(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final hhmm =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today, $hhmm';
    if (diff == 1) return 'Yesterday, $hhmm';
    return '${_months[t.month - 1]} ${t.day}, $hhmm';
  }

  // Dummy "Recent Games" sampai endpoint stats tersedia (UC-18 catatan).
  List<RecentGame> _recentGames() {
    final now = DateTime.now();
    return [
      RecentGame(
          difficulty: 'Medium',
          level: 12,
          playedAt: DateTime(now.year, now.month, now.day, 14, 32),
          points: 9840,
          durationSeconds: 8 * 60 + 42),
      RecentGame(
          difficulty: 'Hard',
          level: 42,
          playedAt: DateTime(now.year, now.month, now.day, 21, 10)
              .subtract(const Duration(days: 1)),
          points: 12400,
          durationSeconds: 14 * 60 + 55),
      RecentGame(
          difficulty: 'Expert',
          level: 5,
          playedAt: DateTime(now.year, 10, 12, 11, 5),
          points: 0,
          durationSeconds: null),
      RecentGame(
          difficulty: 'Easy',
          level: 120,
          playedAt: DateTime(now.year, 10, 11, 18, 32),
          points: 4210,
          durationSeconds: 4 * 60 + 12),
    ];
  }
}
