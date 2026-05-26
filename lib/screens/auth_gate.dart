import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import 'auth/login_screen.dart';
import 'root_shell.dart';

// Auth Gate: tentukan rute awal berdasar token sesi lokal.
// Ada token → Home (RootShell); tidak ada → LoginScreen.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _loggedIn; // null = masih cek

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    // Profil & preferensi sudah dimuat di main() via SettingsService.load().
    final token = await LocalStorageService.getAuthToken();
    if (!mounted) return;
    setState(() => _loggedIn = token != null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) {
      final c = context.colors;
      return Scaffold(
        backgroundColor: c.background,
        body: Center(
          child: CircularProgressIndicator(color: c.primary),
        ),
      );
    }
    return _loggedIn! ? const RootShell() : const LoginScreen();
  }
}
