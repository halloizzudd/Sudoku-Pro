import 'dart:convert';
import 'package:flutter/material.dart';

// UC-21/22/23: preferensi aplikasi yang dipersist & diterapkan instan.
// - themeMode  → MaterialApp.themeMode (UC-22)
// - languageCode → i18n locale (UC-21; integrasi penuh menyusul)
// - notif toggles → sinkron ke endpoint update preferences (UC-23)
class AppSettings {
  final ThemeMode themeMode;
  final String languageCode; // 'en', 'id', 'es', ...
  final bool dailyReminder;
  final bool streakAlert;
  final bool leaderboardUpdate;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.languageCode = 'en',
    this.dailyReminder = true,
    this.streakAlert = true,
    this.leaderboardUpdate = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? dailyReminder,
    bool? streakAlert,
    bool? leaderboardUpdate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      streakAlert: streakAlert ?? this.streakAlert,
      leaderboardUpdate: leaderboardUpdate ?? this.leaderboardUpdate,
    );
  }

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.name,
        'languageCode': languageCode,
        'dailyReminder': dailyReminder,
        'streakAlert': streakAlert,
        'leaderboardUpdate': leaderboardUpdate,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        themeMode: ThemeMode.values.firstWhere(
          (m) => m.name == map['themeMode'],
          orElse: () => ThemeMode.dark,
        ),
        languageCode: map['languageCode'] ?? 'en',
        dailyReminder: map['dailyReminder'] ?? true,
        streakAlert: map['streakAlert'] ?? true,
        leaderboardUpdate: map['leaderboardUpdate'] ?? false,
      );

  String toJson() => json.encode(toMap());
  factory AppSettings.fromJson(String source) =>
      AppSettings.fromMap(json.decode(source));
}

// Daftar bahasa yang tersedia (UC-21). Label tampil di list radio.
const Map<String, String> kSupportedLanguages = {
  'en': 'English',
  'id': 'Bahasa Indonesia',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
  'ja': '日本語',
};
