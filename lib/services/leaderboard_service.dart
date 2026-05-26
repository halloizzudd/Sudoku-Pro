import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';

// UC-16: sumber data leaderboard yang difilter per scope/period.
// Saat backend siap, ganti badan fetch() dengan:
//   GET /leaderboard?scope=global&period=daily&limit=50&offset=0
// dan tambahkan cache 1–5 menit di sini. Untuk MVP dipakai dummy yang
// berbeda per kombinasi filter agar toggle terlihat efeknya.
enum LeaderboardScope { global, friends }

enum LeaderboardPeriod { daily, weekly, allTime }

class LeaderboardPage {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry me; // "Your Ranking" (UC-15 step 5)
  final bool hasMore;

  const LeaderboardPage({
    required this.entries,
    required this.me,
    this.hasMore = false,
  });
}

extension LeaderboardScopeApi on LeaderboardScope {
  String get param => this == LeaderboardScope.global ? 'global' : 'friends';
}

extension LeaderboardPeriodApi on LeaderboardPeriod {
  String get param => switch (this) {
        LeaderboardPeriod.daily => 'daily',
        LeaderboardPeriod.weekly => 'weekly',
        LeaderboardPeriod.allTime => 'allTime',
      };
}

class LeaderboardService {
  // UC-13/15: submit skor saat game menang. MVP: log payload yang akan
  // dikirim ke backend (POST /games/complete → leaderboard). Backend nyata
  // perlu idempotency key (anti double-entry) & validasi waktu minimum.
  static Future<void> submitScoreToServer(int score, String difficulty) async {
    final payload = {
      'score': score,
      'difficulty': difficulty,
      'submittedAt': DateTime.now().toIso8601String(),
    };
    debugPrint('[Leaderboard] POST /leaderboard submit → $payload');
    // TODO: ganti dengan API client + idempotency saat backend tersedia.
  }

  // Refetch dengan parameter baru tiap toggle (UC-16 main flow).
  static Future<LeaderboardPage> fetch({
    required LeaderboardScope scope,
    required LeaderboardPeriod period,
    int limit = 50,
    int offset = 0,
  }) async {
    // Simulasi latency network agar loading state terlihat.
    await Future.delayed(const Duration(milliseconds: 350));

    final entries = _dummy(scope, period);
    final paged = entries.skip(offset).take(limit).toList();
    return LeaderboardPage(
      entries: paged,
      me: _meFor(scope, period),
      hasMore: offset + paged.length < entries.length,
    );
  }

  static List<LeaderboardEntry> _dummy(
      LeaderboardScope scope, LeaderboardPeriod period) {
    if (scope == LeaderboardScope.friends) {
      return const [
        LeaderboardEntry(rank: 1, username: 'NalaGrid', tag: 'LV.15', timeSeconds: 255, score: 8910),
        LeaderboardEntry(rank: 2, username: 'ZenSolver', tag: 'LV.18', timeSeconds: 268, score: 8740),
        LeaderboardEntry(rank: 3, username: 'You', tag: 'LV.12', timeSeconds: 252, score: 8500),
        LeaderboardEntry(rank: 4, username: 'GridRunner', tag: 'LV.14', timeSeconds: 290, score: 8120),
      ];
    }
    // Global: variasikan waktu/score sedikit per period agar refetch terasa.
    final bump = switch (period) {
      LeaderboardPeriod.daily => 0,
      LeaderboardPeriod.weekly => 12,
      LeaderboardPeriod.allTime => 30,
    };
    return [
      LeaderboardEntry(rank: 1, username: 'ARCHITECT', tag: 'MASTER', timeSeconds: 180 + bump, score: 9840 + bump * 5),
      LeaderboardEntry(rank: 2, username: 'ELARA_V', tag: 'EXPERT', timeSeconds: 210 + bump, score: 9420 + bump * 5),
      LeaderboardEntry(rank: 3, username: 'LOGIC_M', tag: 'EXPERT', timeSeconds: 229 + bump, score: 9210 + bump * 5),
      LeaderboardEntry(rank: 4, username: 'MasterMind', tag: 'PRO', timeSeconds: 233 + bump, score: 9100 + bump * 5, isPro: true),
      LeaderboardEntry(rank: 5, username: 'ZenSolver', tag: 'LV.18', timeSeconds: 237 + bump, score: 9020 + bump * 5),
      LeaderboardEntry(rank: 6, username: 'NalaGrid', tag: 'LV.15', timeSeconds: 243 + bump, score: 8910 + bump * 5),
      LeaderboardEntry(rank: 7, username: 'GridRunner', tag: 'LV.14', timeSeconds: 250 + bump, score: 8830 + bump * 5),
    ];
  }

  static LeaderboardEntry _meFor(
      LeaderboardScope scope, LeaderboardPeriod period) {
    if (scope == LeaderboardScope.friends) {
      return const LeaderboardEntry(
          rank: 3, username: 'You', tag: 'LV.12', timeSeconds: 252, score: 8500);
    }
    final rank = switch (period) {
      LeaderboardPeriod.daily => 42,
      LeaderboardPeriod.weekly => 58,
      LeaderboardPeriod.allTime => 121,
    };
    return LeaderboardEntry(
        rank: rank, username: 'You', tag: 'LV.12', timeSeconds: 252, score: 8500);
  }
}
