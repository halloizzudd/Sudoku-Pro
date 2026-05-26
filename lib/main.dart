import 'package:flutter/material.dart';
import 'screens/auth_gate.dart';
import 'services/settings_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.load(); // UC-22: terapkan tema tersimpan saat startup
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF5C4EE5);
    // UC-22: themeMode dari preferensi, diterapkan instan via ValueNotifier.
    return ValueListenableBuilder(
      valueListenable: SettingsService.settings,
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Sudoku Pro',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.light.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.light,
            ),
            extensions: const [AppColors.light],
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.dark.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
            ),
            extensions: const [AppColors.dark],
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}
