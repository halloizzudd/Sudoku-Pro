import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../game/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State simulasi untuk UC-06 & UC-07
  final bool _hasActiveGame = true; // Set true untuk memunculkan 'Continue Game'
  final bool _isMasterUnlocked = false; // Status unlock level Master

  // --- Logika UC-06 ---

  // Fungsi saat tombol difficulty ditekan
  void _onDifficultySelected(String difficulty) {
    if (difficulty == 'MASTER' && !_isMasterUnlocked) {
      // Alternate Flow A1: Level Master terkunci
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selesaikan 10 Expert level untuk unlock Master'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_hasActiveGame) {
      // Alternate Flow A2: Ada game yang sedang berjalan
      _showNewGameConfirmationDialog(difficulty);
    } else {
      // Main Flow: Langsung mulai game
      _startNewGame(difficulty);
    }
  }

  // Dialog konfirmasi timpa progress
  void _showNewGameConfirmationDialog(String difficulty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Mulai Game Baru?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Mulai game baru akan menghapus progress saat ini, lanjutkan?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Batal
              child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _startNewGame(difficulty); // Lanjut buat game baru
              },
              child: const Text('LANJUTKAN', style: TextStyle(color: Color(0xFF5C4EE5))),
            ),
          ],
        );
      },
    );
  }

  // Eksekusi generate puzzle & pindah screen
  void _startNewGame(String difficulty) {
    // TODO: UC-06 — generate puzzle sesuai difficulty. Untuk MVP, pakai
    // dummy puzzle bawaan GameScreen.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0F0F1A);
    const Color cardColor = Color(0xFF1E1E2E);
    const Color textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          'SUDOKU PRO',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: textColor),
            onPressed: () {
              // TODO: Navigasi ke Notifikasi (UC-23)
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Continue Game Banner (UC-07)
              if (_hasActiveGame) _buildContinueGameCard(),
              if (_hasActiveGame) const SizedBox(height: 24),

              // 2. New Game Section (UC-06)
              const Text(
                'NEW GAME',
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select your difficulty',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              
              // Difficulty Grid
              Row(
                children: [
                  Expanded(
                    child: _buildDifficultyCard(
                      'EASY',
                      '3-5 min',
                      Icons.rocket_launch_outlined,
                      const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDifficultyCard(
                      'MEDIUM',
                      '5-10 min',
                      Icons.extension_outlined,
                      const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDifficultyCard(
                      'HARD',
                      '10-20 min',
                      Icons.psychology_outlined,
                      const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDifficultyCard(
                      'EXPERT',
                      '20-40 min',
                      Icons.diamond_outlined,
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Master Level (Locked/Unlocked)
              _buildMasterCard(),
              const SizedBox(height: 24),

              // 3. Quick Stats (Bagian dari UC-18)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('142', 'GAMES WON'),
                    Container(width: 1, height: 40, color: Colors.grey[800]),
                    _buildStatItem('78%', 'WIN RATE'),
                    Container(width: 1, height: 40, color: Colors.grey[800]),
                    _buildStatItem('3:21', 'BEST TIME'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Daily Challenge
              _buildDailyChallengeCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      // Bottom nav disediakan oleh RootShell.
    );
  }

  // --- Widget Builders ---

  Widget _buildContinueGameCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      // ... (styling sama seperti sebelumnya)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ... (teks banner sama seperti sebelumnya)
          OutlinedButton(
            onPressed: () async {
              // UC-07: load saved session. Saat ini GameScreen belum menerima
              // session param — TODO ketika UC-07 wiring lengkap.
              final savedSession = await LocalStorageService.loadActiveGame();
              if (!mounted) return;
              if (savedSession != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal memuat game tersimpan.')),
                );
              }
            },
            // ... (styling tombol sama)
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(String title, String time, IconData icon, Color accentColor) {
    return GestureDetector(
      onTap: () => _onDifficultySelected(title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Icon(icon, color: Colors.grey, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              time,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
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
          color: const Color(0xFF161622), // Warna sedikit lebih gelap karena disabled
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A3C)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MASTER',
                  style: TextStyle(
                    color: _isMasterUnlocked ? const Color(0xFFD946EF) : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isMasterUnlocked ? '40-60 min' : 'Unlock at Level 20', // Mengikuti teks di mockup
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            Icon(
              _isMasterUnlocked ? Icons.workspace_premium : Icons.lock_outline,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildDailyChallengeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        // Simulasi efek cahaya dari mockup
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF1E1E2E),
            const Color(0xFF2A3B5C).withOpacity(0.5),
            const Color(0xFF1E1E2E),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 40), // Ruang untuk visual di atas
          Text('Daily Challenge', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            "Solve today's unique board to earn\nexclusive Master Points.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

}