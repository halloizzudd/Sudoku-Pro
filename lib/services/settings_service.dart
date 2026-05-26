import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/user_profile.dart';
import 'local_storage_service.dart';

// UC-21/22/23 + UC-20: load/save preferensi & profil, terapkan instan lewat
// ValueNotifier yang didengar di root (MaterialApp) dan layar terkait.
class SettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _profileKey = 'user_profile';

  // Sumber kebenaran in-memory yang reaktif. Diinisialisasi default lalu
  // ditimpa oleh load() saat startup.
  static final ValueNotifier<AppSettings> settings =
      ValueNotifier<AppSettings>(const AppSettings());
  static final ValueNotifier<UserProfile> profile =
      ValueNotifier<UserProfile>(const UserProfile());

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_settingsKey);
    if (s != null) settings.value = AppSettings.fromJson(s);
    final p = prefs.getString(_profileKey);
    if (p != null) profile.value = UserProfile.fromJson(p);
  }

  // Apply instan (notifier) + persist (UC-21/22/23 "simpan ke preferences").
  static Future<void> updateSettings(AppSettings next) async {
    settings.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, next.toJson());
    // TODO UC-23: PATCH /users/me/preferences untuk sinkron notif ke backend.
  }

  static Future<void> updateProfile(UserProfile next) async {
    profile.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, next.toJson());
    // TODO UC-20: PATCH /users/me (email baru → trigger re-verify).
  }

  // UC-05/19: logout — hapus token sesi + profil lokal.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await LocalStorageService.clearAuthToken();
    profile.value = const UserProfile();
  }
}
