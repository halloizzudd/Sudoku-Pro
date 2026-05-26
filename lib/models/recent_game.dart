// UC-18 step 3: satu entry pada list "Recent Games" di Stats screen.
// Sumber data akhir: GET /users/me/stats (field recent_games). Untuk MVP
// dipakai dummy in-memory, selaras dengan leaderboard.
class RecentGame {
  final String difficulty; // "Easy" | "Medium" | "Hard" | "Expert" | ...
  final int level;
  final DateTime playedAt;
  final int points; // 0 = game tidak selesai / kalah
  final int? durationSeconds; // null = belum/ tidak selesai → tampil "--:--"

  const RecentGame({
    required this.difficulty,
    required this.level,
    required this.playedAt,
    required this.points,
    this.durationSeconds,
  });

  bool get isCompleted => durationSeconds != null && points > 0;

  factory RecentGame.fromMap(Map<String, dynamic> map) => RecentGame(
        difficulty: map['difficulty'] ?? 'Easy',
        level: map['level']?.toInt() ?? 0,
        playedAt: DateTime.parse(map['playedAt']),
        points: map['points']?.toInt() ?? 0,
        durationSeconds: map['durationSeconds']?.toInt(),
      );

  Map<String, dynamic> toMap() => {
        'difficulty': difficulty,
        'level': level,
        'playedAt': playedAt.toIso8601String(),
        'points': points,
        'durationSeconds': durationSeconds,
      };
}
