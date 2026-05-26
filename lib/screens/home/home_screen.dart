import 'package:flutter/material.dart';
import '../../models/game_session.dart';
import '../../models/player_stats.dart';
import '../../services/local_storage_service.dart';
import '../../services/l10n.dart';
import '../../theme/app_colors.dart';
import '../game/game_screen.dart';
import '../notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameSession? _activeGame; // UC-07: saved game (null = tidak ada)
  PlayerStats _stats = const PlayerStats();
  bool _isMasterUnlocked = false; // GAP-05
  late AppColors c; // diisi di build, dipakai helper

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // Refresh tiap kembali ke Home (mis. setelah selesai game).
  Future<void> _refresh() async {
    final session = await LocalStorageService.loadActiveGame();
    final stats = await LocalStorageService.loadStats();
    if (!mounted) return;
    setState(() {
      _activeGame = session;
      _stats = stats;
      // Asumsi GAP-05: Master unlock setelah 10 kemenangan Expert.
      // Stats belum melacak win per-difficulty → pakai proxy gamesWon >= 10.
      _isMasterUnlocked = stats.gamesWon >= 10;
    });
  }

  String _fmtTime(int s) {
    if (s <= 0) return '--:--';
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  int _bestTimeOverall() {
    int best = 0;
    for (final v in _stats.bestTimeByDifficulty.values) {
      if (v > 0 && (best == 0 || v < best)) best = v;
    }
    return best;
  }

  // 'EASY' → 'Easy' agar konsisten dengan generator & scoring.
  String _titleCase(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  // --- UC-06 ---
  void _onDifficultySelected(String difficulty) {
    if (difficulty == 'MASTER' && !_isMasterUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.t('unlockMasterToast')),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_activeGame != null) {
      _showNewGameConfirmationDialog(difficulty); // A2
    } else {
      _startNewGame(difficulty);
    }
  }

  void _showNewGameConfirmationDialog(String difficulty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: Text(L10n.t('startNewGameTitle'),
              style: const TextStyle(color: Colors.white)),
          content: Text(
            L10n.t('startNewGameBody'),
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text(L10n.t('cancel'), style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startNewGame(difficulty);
              },
              child: Text(L10n.t('continueBtn'),
                  style: const TextStyle(color: Color(0xFF5C4EE5))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startNewGame(String difficultyLabel) async {
    final difficulty = _titleCase(difficultyLabel);
    final level = _stats.gamesWon + 1; // level naik tiap menang
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(difficulty: difficulty, level: level),
      ),
    );
    _refresh(); // sync continue-card & stats setelah kembali
  }

  Future<void> _continueGame() async {
    final session = _activeGame;
    if (session == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(resumeSession: session)),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    c = context.colors;
    final Color bgColor = c.background;
    final Color cardColor = c.surface;
    final Color textColor = c.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'SUDOKU PRO',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: textColor),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFFF59E0B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Continue Game (UC-07)
                if (_activeGame != null) _buildContinueGameCard(_activeGame!),
                if (_activeGame != null) const SizedBox(height: 24),

                // 2. New Game (UC-06)
                Text(L10n.t('newGame'),
                    style: const TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(L10n.t('selectDifficulty'),
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDifficultyCard('EASY', '3-5 min',
                          Icons.rocket_launch_outlined, const Color(0xFF22C55E)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyCard('MEDIUM', '5-10 min',
                          Icons.extension_outlined, const Color(0xFFF59E0B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDifficultyCard('HARD', '10-20 min',
                          Icons.psychology_outlined, const Color(0xFFEF4444)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyCard('EXPERT', '20-40 min',
                          Icons.diamond_outlined, const Color(0xFF8B5CF6)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMasterCard(),
                const SizedBox(height: 24),

                // 3. Quick Stats (UC-18, data nyata)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                          '${_stats.gamesWon}', L10n.t('gamesWon')),
                      Container(width: 1, height: 40, color: Colors.grey[800]),
                      _buildStatItem('${(_stats.winRate * 100).round()}%',
                          L10n.t('winRate')),
                      Container(width: 1, height: 40, color: Colors.grey[800]),
                      _buildStatItem(
                          _fmtTime(_bestTimeOverall()), L10n.t('bestTime')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDailyChallengeCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueGameCard(GameSession s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF5C4EE5), Color(0xFF7C6CF5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.t('continueGame'),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              const SizedBox(height: 6),
              Text('${s.difficulty} • Level ${s.level}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                  '${_fmtTime(s.elapsedSeconds)} ${L10n.t('elapsed')} • ${s.mistakes}/3 ${L10n.t('mistakesShort')}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          OutlinedButton(
            onPressed: _continueGame,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(L10n.t('continueBtn'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(
      String title, String time, IconData icon, Color accentColor) {
    return GestureDetector(
      onTap: () => _onDifficultySelected(title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Icon(icon, color: c.textSecondary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(time,
                style: TextStyle(color: c.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterCard() {
    return GestureDetector(
      onTap: () => _onDifficultySelected('MASTER'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MASTER',
                    style: TextStyle(
                      color: _isMasterUnlocked
                          ? const Color(0xFFD946EF)
                          : c.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
                const SizedBox(height: 8),
                Text(
                  _isMasterUnlocked ? '40-60 min' : L10n.t('unlockMaster'),
                  style: TextStyle(color: c.textSecondary, fontSize: 14),
                ),
              ],
            ),
            Icon(
              _isMasterUnlocked
                  ? Icons.workspace_premium
                  : Icons.lock_outline,
              color: _isMasterUnlocked
                  ? const Color(0xFFD946EF)
                  : c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: c.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildDailyChallengeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            c.surface,
            const Color(0xFF2A3B5C).withOpacity(0.35),
            c.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(L10n.t('dailyChallenge'),
              style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            L10n.t('dailyChallengeDesc'),
            style: TextStyle(color: c.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
