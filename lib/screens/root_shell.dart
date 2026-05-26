import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home/home_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'stats/stats_screen.dart';
import 'profile/profile_screen.dart';

// App shell yang menjalankan bottom navigation 4 tab.
// Memakai IndexedStack agar state tiap tab tetap hidup saat switch.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    LeaderboardScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: c.surface,
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          selectedItemColor: c.accent,
          unselectedItemColor: c.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'PLAY'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'RANKS'),
            BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined), label: 'STATS'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
          ],
        ),
      ),
    );
  }
}
