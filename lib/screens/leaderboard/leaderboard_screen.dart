import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';
import '../../services/leaderboard_service.dart';
import 'components/podium.dart';
import 'components/scope_filter.dart';
import 'components/leaderboard_list.dart';

// UC-15 + UC-16: Leaderboard global/friends × daily/weekly/all-time.
// Default state per spec: Global + Daily. Tiap toggle memicu refetch dengan
// parameter baru (UC-16).
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.global;
  LeaderboardPeriod _period = LeaderboardPeriod.daily;

  LeaderboardPage? _page;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refetch();
  }

  // UC-16: refetch dengan parameter scope/period terbaru.
  Future<void> _refetch() async {
    setState(() => _loading = true);
    final page = await LeaderboardService.fetch(
      scope: _scope,
      period: _period,
    );
    if (!mounted) return;
    setState(() {
      _page = page;
      _loading = false;
    });
  }

  void _onScopeChanged(LeaderboardScope s) {
    if (s == _scope) return;
    setState(() => _scope = s);
    _refetch();
  }

  void _onPeriodChanged(LeaderboardPeriod p) {
    if (p == _period) return;
    setState(() => _period = p);
    _refetch();
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;
    final entries = page?.entries ?? const <LeaderboardEntry>[];
    final top3 = entries.take(3).toList();
    final rest = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text(
          'SUDOKU PRO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {}, // TODO: cari user di leaderboard
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ScopeFilter(
                scope: _scope,
                period: _period,
                onScopeChanged: _onScopeChanged,
                onPeriodChanged: _onPeriodChanged,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C4EE5)))
                  : entries.isEmpty
                      ? const Center(
                          child: Text('No rankings yet',
                              style: TextStyle(color: Colors.grey)),
                        )
                      : Column(
                          children: [
                            Podium(top3: top3),
                            const SizedBox(height: 16),
                            Expanded(
                              child: LeaderboardList(
                                entries: rest,
                                onLoadMore: () {
                                  // TODO: pagination/infinite scroll (catatan UC-15)
                                },
                              ),
                            ),
                          ],
                        ),
            ),
            if (page != null) _yourRankingBar(page.me),
          ],
        ),
      ),
    );
  }

  // UC-15 step 5: sticky "Your Ranking" bar di bawah.
  Widget _yourRankingBar(LeaderboardEntry me) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5C4EE5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text('#${me.rank}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF2A2A4A),
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(me.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(_formatTime(me.timeSeconds),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('SHARE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  static String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
