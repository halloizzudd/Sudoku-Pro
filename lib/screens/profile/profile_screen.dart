import 'package:flutter/material.dart';
import '../../models/player_stats.dart';
import '../../models/user_profile.dart';
import '../../services/local_storage_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';
import '../friends/friends_screen.dart';
import '../notifications_screen.dart';
import 'edit_profile_screen.dart';
import 'appearance_screen.dart';
import 'notifications_screen.dart' as settings_notif;
import 'privacy_security_screen.dart';

// UC-19: Profile. Avatar (+PRO badge), username, rank title, ringkasan stats
// 3 kolom, current rank card, menu settings, logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _indigo = Color(0xFF5C4EE5);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _danger = Color(0xFFEF4444);

  late AppColors c;
  PlayerStats _stats = const PlayerStats();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final s = await LocalStorageService.loadStats();
    if (!mounted) return;
    setState(() => _stats = s);
  }

  int _bestTimeOverall() {
    int best = 0;
    for (final v in _stats.bestTimeByDifficulty.values) {
      if (v > 0 && (best == 0 || v < best)) best = v;
    }
    return best;
  }

  static String _fmtTime(int s) {
    if (s <= 0) return '--:--';
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        title: Text('SUDOKU PRO',
            style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: c.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<UserProfile>(
        valueListenable: SettingsService.profile,
        builder: (context, profile, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const SizedBox(height: 8),
              _header(profile),
              const SizedBox(height: 24),
              _statsSummary(),
              const SizedBox(height: 20),
              _currentRankCard(profile.rankTitle),
              const SizedBox(height: 20),
              _menuItem(Icons.person_outline, 'Edit Profile',
                  () => _open(const EditProfileScreen())),
              _menuItem(Icons.people_outline, 'Friends',
                  () => _open(const FriendsScreen())),
              _menuItem(Icons.palette_outlined, 'Appearance',
                  () => _open(const AppearanceScreen())),
              _menuItem(Icons.notifications_none, 'Notifications',
                  () => _open(const settings_notif.NotificationsScreen())),
              _menuItem(Icons.lock_outline, 'Privacy & Security',
                  () => _open(const PrivacySecurityScreen())),
              const SizedBox(height: 4),
              _logoutItem(),
            ],
          );
        },
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _header(UserProfile profile) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_indigo, Color(0xFF8B7BFF)]),
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: c.surface,
                backgroundImage: profile.avatarPath != null
                    ? AssetImage(profile.avatarPath!)
                    : null,
                child: profile.avatarPath == null
                    ? Icon(Icons.person, color: c.textSecondary, size: 44)
                    : null,
              ),
            ),
            if (profile.isPro)
              Positioned(
                bottom: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _amber,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: c.background, width: 2),
                  ),
                  child: const Text('PRO',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(profile.username,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(profile.rankTitle,
            style: TextStyle(color: c.textSecondary, fontSize: 15)),
      ],
    );
  }

  Widget _statsSummary() {
    final winRate = (_stats.winRate * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _summaryCol('${_stats.gamesWon}', 'GAMES WON'),
            _divider(),
            _summaryCol('$winRate%', 'WIN RATE'),
            _divider(),
            _summaryCol(_fmtTime(_bestTimeOverall()), 'BEST TIME'),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      VerticalDivider(color: c.divider, thickness: 1, width: 1);

  Widget _summaryCol(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _currentRankCard(String rankTitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_indigo, Color(0xFF7C6CF5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events, color: _amber),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CURRENT RANK',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(rankTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: c.textPrimary),
        title: Text(label,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right, color: c.textSecondary),
        onTap: onTap,
      ),
    );
  }

  Widget _logoutItem() {
    return Container(
      decoration: BoxDecoration(
        color: _danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: const Icon(Icons.logout, color: _danger),
        title: const Text('Logout',
            style: TextStyle(
                color: _danger, fontSize: 15, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: _danger),
        onTap: _confirmLogout,
      ),
    );
  }

  // UC-19: konfirmasi logout (modal sesuai mockup).
  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => Dialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _danger.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: _danger, size: 26),
              ),
              const SizedBox(height: 16),
              Text('Logout?',
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to log out? You'll need to sign in "
                'again to access your stats and progress.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: c.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: c.gridLine),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      await SettingsService.logout();
      if (!mounted) return;
      // UC-05: kembali ke Login, hapus seluruh stack navigasi.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
