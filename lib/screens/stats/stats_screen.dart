import 'package:flutter/material.dart';
import '../../models/player_stats.dart';
import '../../services/local_storage_service.dart';

// Placeholder Stats tab. Menampilkan agregat dari PlayerStats yang
// dipersist oleh UC-13 / UC-14. Layout penuh menyusul (UC-18).
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  PlayerStats _stats = const PlayerStats();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await LocalStorageService.loadStats();
    if (!mounted) return;
    setState(() {
      _stats = s;
      _loading = false;
    });
  }

  String _fmtTime(int s) {
    if (s == 0) return '—';
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text('STATS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _tile('Games played', '${_stats.gamesPlayed}'),
                  _tile('Games won', '${_stats.gamesWon}'),
                  _tile('Win rate', '${(_stats.winRate * 100).toStringAsFixed(0)}%'),
                  _tile('Current streak', '${_stats.currentStreak}'),
                  _tile('Longest streak', '${_stats.longestStreak}'),
                  const SizedBox(height: 16),
                  const Text('BEST TIME PER DIFFICULTY',
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final d in const ['Easy', 'Medium', 'Hard', 'Expert', 'Master'])
                    _tile(d, _fmtTime(_stats.bestTimeFor(d))),
                ],
              ),
            ),
    );
  }

  Widget _tile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Text(value, style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
