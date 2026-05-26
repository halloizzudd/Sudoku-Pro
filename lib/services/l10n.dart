import 'settings_service.dart';

// UC-21: lokalisasi sederhana berbasis dictionary statis (EN + ID).
// Bahasa lain fallback ke EN. String diambil saat build; perubahan bahasa
// memicu rebuild via ValueListenableBuilder di main() → terapan instan.
class L10n {
  static String t(String key) {
    final code = SettingsService.settings.value.languageCode;
    final map = code == 'id' ? _id : _en;
    return map[key] ?? _en[key] ?? key;
  }

  static const Map<String, String> _en = {
    // Home
    'newGame': 'NEW GAME',
    'selectDifficulty': 'Select your difficulty',
    'continueGame': 'CONTINUE GAME',
    'continueBtn': 'CONTINUE',
    'gamesWon': 'GAMES WON',
    'winRate': 'WIN RATE',
    'bestTime': 'BEST TIME',
    'dailyChallenge': 'Daily Challenge',
    'dailyChallengeDesc':
        "Solve today's unique board to earn\nexclusive Master Points.",
    'unlockMaster': 'Win 10 games to unlock',
    'startNewGameTitle': 'Start a new game?',
    'startNewGameBody':
        'Starting a new game will discard your current progress. Continue?',
    'cancel': 'CANCEL',
    'elapsed': 'elapsed',
    'mistakesShort': 'mistakes',
    'unlockMasterToast': 'Win 10 games to unlock Master',
    // Appearance / Settings
    'appearance': 'APPEARANCE',
    'theme': 'THEME',
    'light': 'Light',
    'dark': 'Dark',
    'systemDefault': 'System default',
    'language': 'LANGUAGE',
    'languageNote': 'Full translations are being rolled out gradually.',
    'notifications': 'NOTIFICATIONS',
    'dailyReminder': 'Daily Reminder',
    'dailyReminderDesc': 'A nudge to play a puzzle each day',
    'streakAlert': 'Streak Alert',
    'streakAlertDesc': 'Warn me before I lose my streak',
    'leaderboardUpdate': 'Leaderboard Update',
    'leaderboardUpdateDesc': 'When my rank changes',
    // Game
    'mistakes': 'MISTAKES',
    'undo': 'UNDO',
    'erase': 'ERASE',
    'notes': 'NOTES',
    'hint': 'HINT',
    'paused': 'Paused',
    'resume': 'RESUME',
    'generatingPuzzle': 'Generating puzzle…',
  };

  static const Map<String, String> _id = {
    // Home
    'newGame': 'GAME BARU',
    'selectDifficulty': 'Pilih tingkat kesulitan',
    'continueGame': 'LANJUTKAN GAME',
    'continueBtn': 'LANJUTKAN',
    'gamesWon': 'MENANG',
    'winRate': 'RASIO MENANG',
    'bestTime': 'WAKTU TERBAIK',
    'dailyChallenge': 'Tantangan Harian',
    'dailyChallengeDesc':
        'Selesaikan papan unik hari ini untuk\nmeraih Master Points eksklusif.',
    'unlockMaster': 'Menangi 10 game untuk membuka',
    'startNewGameTitle': 'Mulai game baru?',
    'startNewGameBody':
        'Memulai game baru akan menghapus progres saat ini. Lanjutkan?',
    'cancel': 'BATAL',
    'elapsed': 'berlalu',
    'mistakesShort': 'kesalahan',
    'unlockMasterToast': 'Menangi 10 game untuk membuka Master',
    // Appearance / Settings
    'appearance': 'TAMPILAN',
    'theme': 'TEMA',
    'light': 'Terang',
    'dark': 'Gelap',
    'systemDefault': 'Ikuti sistem',
    'language': 'BAHASA',
    'languageNote': 'Terjemahan penuh sedang diluncurkan bertahap.',
    'notifications': 'NOTIFIKASI',
    'dailyReminder': 'Pengingat Harian',
    'dailyReminderDesc': 'Ajakan bermain puzzle setiap hari',
    'streakAlert': 'Peringatan Streak',
    'streakAlertDesc': 'Ingatkan sebelum streak-ku putus',
    'leaderboardUpdate': 'Pembaruan Peringkat',
    'leaderboardUpdateDesc': 'Saat peringkatku berubah',
    // Game
    'mistakes': 'KESALAHAN',
    'undo': 'URUNGKAN',
    'erase': 'HAPUS',
    'notes': 'CATATAN',
    'hint': 'PETUNJUK',
    'paused': 'Dijeda',
    'resume': 'LANJUT',
    'generatingPuzzle': 'Membuat puzzle…',
  };
}
