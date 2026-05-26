import 'package:flutter/material.dart';
import '../../models/app_settings.dart';
import '../../services/settings_service.dart';
import '../../services/l10n.dart';

// UC-22 (Theme) + UC-21 (Language). Pilih opsi → simpan ke preferences →
// terapkan instan via SettingsService notifier.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

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
        title: Text(L10n.t('appearance'),
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
              _sectionLabel(L10n.t('theme')),
              _card_(
                child: Column(
                  children: [
                    _themeOption(L10n.t('light'), ThemeMode.light, settings),
                    _sep(),
                    _themeOption(L10n.t('dark'), ThemeMode.dark, settings),
                    _sep(),
                    _themeOption(
                        L10n.t('systemDefault'), ThemeMode.system, settings),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionLabel(L10n.t('language')),
              _card_(
                child: Column(
                  children: [
                    for (int i = 0;
                        i < kSupportedLanguages.length;
                        i++) ...[
                      if (i > 0) _sep(),
                      _languageOption(
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
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _themeOption(String label, ThemeMode mode, AppSettings settings) {
    final selected = settings.themeMode == mode;
    return _radioRow(
      label: label,
      selected: selected,
      onTap: () =>
          SettingsService.updateSettings(settings.copyWith(themeMode: mode)),
    );
  }

  Widget _languageOption(String code, String label, AppSettings settings) {
    final selected = settings.languageCode == code;
    return _radioRow(
      label: label,
      selected: selected,
      onTap: () => SettingsService.updateSettings(
          settings.copyWith(languageCode: code)),
    );
  }

  Widget _radioRow({
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
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? _indigo : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8)),
      );

  Widget _card_({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );

  Widget _sep() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFF26263C));
}
