import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';
import '../../services/leaderboard_service.dart';
import '../../theme/app_colors.dart';
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
    final c = context.colors;
    final page = _page;
    final entries = page?.entries ?? const <LeaderboardEntry>[];
    final top3 = entries.take(3).toList();
    final rest = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        title: Text(
          'SUDOKU PRO',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: c.textPrimary),
            onPressed: () => showSearch(
              context: context,
              delegate: _LeaderboardSearchDelegate(entries, c),
            ),
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
                  ? Center(child: CircularProgressIndicator(color: c.primary))
                  : entries.isEmpty
                      ? Center(
                          child: Text('No rankings yet',
                              style: TextStyle(color: c.textSecondary)),
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
            if (page != null) _yourRankingBar(c, page.me),
          ],
        ),
      ),
    );
  }

  // UC-15 step 5: sticky "Your Ranking" bar di bawah.
  Widget _yourRankingBar(AppColors c, LeaderboardEntry me) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.primary,
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

// Pencarian user di leaderboard (memfilter entri yang sudah dimuat).
class _LeaderboardSearchDelegate extends SearchDelegate<void> {
  final List<LeaderboardEntry> entries;
  final AppColors c;

  _LeaderboardSearchDelegate(this.entries, this.c)
      : super(searchFieldLabel: 'Search players');

  static String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
        titleTextStyle: TextStyle(color: c.textPrimary, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: c.textSecondary),
        border: InputBorder.none,
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: TextStyle(color: c.textPrimary, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear, color: c.textPrimary),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: Icon(Icons.arrow_back, color: c.textPrimary),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _list();

  @override
  Widget buildSuggestions(BuildContext context) => _list();

  Widget _list() {
    final q = query.trim().toLowerCase();
    final matches = q.isEmpty
        ? entries
        : entries
            .where((e) => e.username.toLowerCase().contains(q))
            .toList();

    if (matches.isEmpty) {
      return Container(
        color: c.background,
        alignment: Alignment.center,
        child: Text('No players found',
            style: TextStyle(color: c.textSecondary)),
      );
    }

    return Container(
      color: c.background,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: matches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = matches[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text('#${e.rank}',
                      style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.username,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.bold)),
                ),
                Text(_fmt(e.timeSeconds),
                    style: TextStyle(color: c.textSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }
}
