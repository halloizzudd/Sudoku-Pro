import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';
import 'components/podium.dart';
import 'components/scope_filter.dart';
import 'components/leaderboard_list.dart';

// UC-15: Leaderboard global/friends × daily/weekly/all-time.
// Default state per spec: Global + Daily.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

enum LeaderboardScope { global, friends }

enum LeaderboardRange { daily, weekly, allTime }

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.global;
  LeaderboardRange _range = LeaderboardRange.daily;

  // Dummy data sampai backend leaderboard tersedia.
  // TODO: ganti dengan fetch + cache 1–5 menit (catatan UC-15).
  static const List<LeaderboardEntry> _allEntries = [
    LeaderboardEntry(rank: 1, username: 'ARCHITECT', tag: 'MASTER', timeSeconds: 195, score: 9840),
    LeaderboardEntry(rank: 2, username: 'ELARA_V', tag: 'EXPERT', timeSeconds: 222, score: 9420),
    LeaderboardEntry(rank: 3, username: 'LOGIC_M', tag: 'EXPERT', timeSeconds: 241, score: 9210),
    LeaderboardEntry(rank: 4, username: 'MasterMind', tag: 'PRO', timeSeconds: 245, score: 9100, isPro: true),
    LeaderboardEntry(rank: 5, username: 'ZenSolver', tag: 'LV.18', timeSeconds: 249, score: 9020),
    LeaderboardEntry(rank: 6, username: 'NalaGrid', tag: 'LV.15', timeSeconds: 255, score: 8910),
    LeaderboardEntry(rank: 7, username: 'GridRunner', tag: 'LV.14', timeSeconds: 262, score: 8830),
  ];

  // UC-15 Step 5: "Your Ranking" sticky bar
  static const LeaderboardEntry _you = LeaderboardEntry(
    rank: 42,
    username: 'You',
    tag: 'LV.12',
    timeSeconds: 252,
    score: 8500,
  );

  @override
  Widget build(BuildContext context) {
    final entries = _allEntries; // filter by scope/range akan ditambahkan saat backend siap
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
                range: _range,
                onScopeChanged: (s) => setState(() => _scope = s),
                onRangeChanged: (r) => setState(() => _range = r),
              ),
            ),
            const SizedBox(height: 16),
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
            _yourRankingBar(_you),
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
