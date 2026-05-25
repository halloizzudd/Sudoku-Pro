// Entry baris leaderboard (UC-15). Sumber data: backend nantinya,
// untuk MVP UI dipakai dummy in-memory.
class LeaderboardEntry {
  final int rank;
  final String username;
  final String tag; // contoh: "MASTER", "PRO", "LV.12"
  final int timeSeconds;
  final int score;
  final bool isPro;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.tag,
    required this.timeSeconds,
    required this.score,
    this.isPro = false,
  });
}
