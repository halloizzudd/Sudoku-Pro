import 'package:flutter/material.dart';
import '../../models/app_settings.dart';
import '../../services/settings_service.dart';
import '../../services/l10n.dart';

// UC-23: Notifications — toggle Daily Reminder, Streak Alert, Leaderboard
// Update. Simpan ke preferences (TODO: PATCH /users/me/preferences).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color _bg = Color(0xFF0F0F1A);
  static const Color _card = Color(0xFF1A1A2E);
  static const Color _indigo = Color(0xFF5C4EE5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(L10n.t('notifications'),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ),
      body: ValueListenableBuilder<AppSettings>(
        valueListenable: SettingsService.settings,
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _toggle(
                      title: L10n.t('dailyReminder'),
                      subtitle: L10n.t('dailyReminderDesc'),
                      value: settings.dailyReminder,
                      onChanged: (v) => SettingsService.updateSettings(
                          settings.copyWith(dailyReminder: v)),
                    ),
                    _sep(),
                    _toggle(
                      title: L10n.t('streakAlert'),
                      subtitle: L10n.t('streakAlertDesc'),
                      value: settings.streakAlert,
                      onChanged: (v) => SettingsService.updateSettings(
                          settings.copyWith(streakAlert: v)),
                    ),
                    _sep(),
                    _toggle(
                      title: L10n.t('leaderboardUpdate'),
                      subtitle: L10n.t('leaderboardUpdateDesc'),
                      value: settings.leaderboardUpdate,
                      onChanged: (v) => SettingsService.updateSettings(
                          settings.copyWith(leaderboardUpdate: v)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
      value: value,
      activeColor: Colors.white,
      activeTrackColor: _indigo,
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: const Color(0xFF2A2A40),
      onChanged: onChanged,
    );
  }

  Widget _sep() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFF26263C));
}
