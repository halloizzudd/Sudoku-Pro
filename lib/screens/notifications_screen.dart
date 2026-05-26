import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Task 1: pusat notifikasi (dibuka dari ikon bel). Untuk MVP menampilkan
// beberapa alert dummy; jika kosong tampilkan empty-state.
class _Alert {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  const _Alert(this.icon, this.title, this.body, this.time);
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<_Alert> _alerts = [
    _Alert(Icons.local_fire_department, 'Keep your streak alive!',
        'Play a puzzle today so you don\'t lose your streak.', '2h ago'),
    _Alert(Icons.emoji_events_outlined, 'You moved up the leaderboard',
        'You climbed to #42 this week. Nice work!', 'Yesterday'),
    _Alert(Icons.calendar_today, 'New Daily Challenge',
        'Today\'s unique board is ready. Earn Master Points!', 'Yesterday'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
        title: Text('NOTIFICATIONS',
            style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ),
      body: _alerts.isEmpty
          ? _emptyState(c)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _tile(c, _alerts[i]),
            ),
    );
  }

  Widget _emptyState(AppColors c) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined,
              color: c.textSecondary, size: 56),
          const SizedBox(height: 16),
          Text('No new notifications',
              style: TextStyle(color: c.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _tile(AppColors c, _Alert a) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(a.icon, color: c.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(a.title,
                          style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(a.time,
                        style:
                            TextStyle(color: c.textSecondary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(a.body,
                    style: TextStyle(color: c.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
