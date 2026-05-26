import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_session.dart';
import '../models/player_stats.dart';

class LocalStorageService {
  static const String _activeGameKey = 'active_game_session';
  static const String _statsKey = 'player_stats';
  static const String _authTokenKey = 'auth_token';

  // UC-01/02/04/05 + Auth Gate: token sesi (mock untuk MVP).
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<bool> isLoggedIn() async => (await getAuthToken()) != null;

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  // Menyimpan progress game (Dipanggil dengan debounce saat user input di UC-08)
  static Future<void> saveGameSession(GameSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeGameKey, session.toJson());
  }

  // Meload game (UC-07 - Step 3)
  static Future<GameSession?> loadActiveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionJson = prefs.getString(_activeGameKey);
    
    if (sessionJson != null) {
      return GameSession.fromJson(sessionJson);
    }
    return null; // A1: Tidak ada saved game
  }

  // Menghapus game saat selesai atau Game Over
  static Future<void> clearActiveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeGameKey);
  }

  // UC-13 / UC-14: stats agregat pemain
  static Future<PlayerStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null) return const PlayerStats();
    return PlayerStats.fromJson(raw);
  }

  static Future<void> saveStats(PlayerStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, stats.toJson());
  }
}