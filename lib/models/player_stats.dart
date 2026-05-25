import 'dart:convert';

// UC-13 step 5 & UC-14 step 4: agregat statistik pemain yang dipersist
// antar-session. Disimpan per-difficulty agar best_time relevan.
class PlayerStats {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> bestTimeByDifficulty; // detik; 0 = belum ada
  final String? lastWinDateIso; // YYYY-MM-DD; pakai untuk streak harian

  const PlayerStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.bestTimeByDifficulty = const {},
    this.lastWinDateIso,
  });

  double get winRate => gamesPlayed == 0 ? 0 : gamesWon / gamesPlayed;

  int bestTimeFor(String difficulty) =>
      bestTimeByDifficulty[difficulty] ?? 0;

  PlayerStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? currentStreak,
    int? longestStreak,
    Map<String, int>? bestTimeByDifficulty,
    String? lastWinDateIso,
  }) {
    return PlayerStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      bestTimeByDifficulty:
          bestTimeByDifficulty ?? this.bestTimeByDifficulty,
      lastWinDateIso: lastWinDateIso ?? this.lastWinDateIso,
    );
  }

  Map<String, dynamic> toMap() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'bestTimeByDifficulty': bestTimeByDifficulty,
        'lastWinDateIso': lastWinDateIso,
      };

  factory PlayerStats.fromMap(Map<String, dynamic> map) => PlayerStats(
        gamesPlayed: map['gamesPlayed'] ?? 0,
        gamesWon: map['gamesWon'] ?? 0,
        currentStreak: map['currentStreak'] ?? 0,
        longestStreak: map['longestStreak'] ?? 0,
        bestTimeByDifficulty:
            Map<String, int>.from(map['bestTimeByDifficulty'] ?? const {}),
        lastWinDateIso: map['lastWinDateIso'],
      );

  String toJson() => json.encode(toMap());
  factory PlayerStats.fromJson(String source) =>
      PlayerStats.fromMap(json.decode(source));
}
