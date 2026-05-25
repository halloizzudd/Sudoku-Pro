import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0F0F1A),
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          selectedItemColor: const Color(0xFFF59E0B),
          unselectedItemColor: Colors.grey,
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
