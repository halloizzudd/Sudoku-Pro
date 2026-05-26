import 'package:flutter/material.dart';
import '../../models/app_settings.dart';
import '../../services/settings_service.dart';
import '../../services/l10n.dart';
import '../../theme/app_colors.dart';

// UC-22 (Theme) + UC-21 (Language). Pilih opsi → simpan ke preferences →
// terapkan instan via SettingsService notifier.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
        title: Text(L10n.t('appearance'),
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
              _sectionLabel(c, L10n.t('theme')),
              _card_(
                c,
                child: Column(
                  children: [
                    _themeOption(c, L10n.t('light'), ThemeMode.light, settings),
                    _sep(c),
                    _themeOption(c, L10n.t('dark'), ThemeMode.dark, settings),
                    _sep(c),
                    _themeOption(
                        c, L10n.t('systemDefault'), ThemeMode.system, settings),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionLabel(c, L10n.t('language')),
              _card_(
                c,
                child: Column(
                  children: [
                    for (int i = 0;
                        i < kSupportedLanguages.length;
                        i++) ...[
                      if (i > 0) _sep(c),
                      _languageOption(
                        c,
                        kSupportedLanguages.keys.elementAt(i),
                        kSupportedLanguages.values.elementAt(i),
                        settings,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(L10n.t('languageNote'),
                    style: TextStyle(color: c.textSecondary, fontSize: 11)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _themeOption(
      AppColors c, String label, ThemeMode mode, AppSettings settings) {
    final selected = settings.themeMode == mode;
    return _radioRow(
      c,
      label: label,
      selected: selected,
      onTap: () =>
          SettingsService.updateSettings(settings.copyWith(themeMode: mode)),
    );
  }

  Widget _languageOption(
      AppColors c, String code, String label, AppSettings settings) {
    final selected = settings.languageCode == code;
    return _radioRow(
      c,
      label: label,
      selected: selected,
      onTap: () => SettingsService.updateSettings(
          settings.copyWith(languageCode: code)),
    );
  }

  Widget _radioRow(
    AppColors c, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(color: c.textPrimary, fontSize: 15)),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? c.primary : c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(AppColors c, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text,
            style: TextStyle(
                color: c.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8)),
      );

  Widget _card_(AppColors c, {required Widget child}) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );

  Widget _sep(AppColors c) =>
      Divider(height: 1, thickness: 1, color: c.divider);
}
