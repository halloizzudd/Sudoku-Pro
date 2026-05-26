import 'package:flutter/material.dart';
import '../../models/app_settings.dart';
import '../../services/settings_service.dart';
import '../../services/l10n.dart';
import '../../theme/app_colors.dart';

// UC-23: Notifications — toggle Daily Reminder, Streak Alert, Leaderboard
// Update. Simpan ke preferences (TODO: PATCH /users/me/preferences).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
        title: Text(L10n.t('notifications'),
            style: TextStyle(
                color: c.textPrimary,
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
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _toggle(
                      c,
                      title: L10n.t('dailyReminder'),
                      subtitle: L10n.t('dailyReminderDesc'),
                      value: settings.dailyReminder,
                      onChanged: (v) => SettingsService.updateSettings(
                          settings.copyWith(dailyReminder: v)),
                    ),
                    _sep(c),
                    _toggle(
                      c,
                      title: L10n.t('streakAlert'),
                      subtitle: L10n.t('streakAlertDesc'),
                      value: settings.streakAlert,
                      onChanged: (v) => SettingsService.updateSettings(
                          settings.copyWith(streakAlert: v)),
                    ),
                    _sep(c),
                    _toggle(
                      c,
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

  Widget _toggle(
    AppColors c, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title,
          style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(color: c.textSecondary, fontSize: 12)),
      value: value,
      activeColor: Colors.white,
      activeTrackColor: c.primary,
      inactiveThumbColor: c.textSecondary,
      inactiveTrackColor: c.surface2,
      onChanged: onChanged,
    );
  }

  Widget _sep(AppColors c) =>
      Divider(height: 1, thickness: 1, color: c.divider);
}
