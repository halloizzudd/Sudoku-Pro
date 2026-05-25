import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/game_action.dart';
import '../../models/game_session.dart';
import '../../models/player_stats.dart';
import '../../services/local_storage_service.dart';
import 'game_completed_modal.dart';
import 'game_over_modal.dart';
import 'components/SudokuGrid.dart';
import 'components/NumberPad.dart';
import 'components/ActionBar.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // State Permainan (Idealnya dimuat dari GameSession - UC-07)
  // 0 melambangkan sel kosong.
  final List<int> _puzzle = List.filled(81, 0); // Clue awal
  final List<int> _solution = List.filled(81, 1); // Solusi penuh (Dummy untuk validasi)
  late List<int> _currentBoard; // State board saat ini
  // UC-11: notes per sel (1..9). Set kosong = tidak ada pencil mark.
  final List<Set<int>> _notes = List.generate(81, (_) => <int>{});
  
  static const int _maxHints = 3; // UC-12: quota default

  int? _selectedCellIndex;
  int _mistakes = 0;
  int _hintsUsed = 0;
  int _elapsedSeconds = 0;
  bool _isNotesMode = false;
  late final String _sessionId;

  final List<GameAction> _undoStack = [];
  Timer? _saveDebounce;
  Timer? _gameTimer; // UC-13: ticker untuk completion time

  @override
  void initState() {
    super.initState();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    // Setup Dummy Data (Silakan integrasikan dengan puzzle generator nantinya)
    _currentBoard = List.from(_puzzle);
    _puzzle[0] = 5; _puzzle[1] = 3; _puzzle[2] = 4; // Contoh clue pre-filled
    _currentBoard[0] = 5; _currentBoard[1] = 3; _currentBoard[2] = 4;
    _startTimer();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // UC-08 Step 8: Auto-save dengan debounce agar tidak hit storage tiap tap.
  void _scheduleAutoSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      LocalStorageService.saveGameSession(GameSession(
        id: _sessionId,
        difficulty: 'Medium',
        puzzle: _puzzle,
        currentBoard: _currentBoard,
        mistakes: _mistakes,
        hintsUsed: _hintsUsed,
        elapsedSeconds: _elapsedSeconds,
      ));
    });
  }

  // --- LOGIKA UC-08 ---

  void _onCellTapped(int index) {
    // UC-08 - Alternate Flow A1: Sel adalah clue awal (read-only)
    if (_puzzle[index] != 0) return;

    setState(() {
      _selectedCellIndex = index;
    });
  }

  void _onNumberPressed(int number) {
    if (_selectedCellIndex == null) return;
    
    // Pastikan sel yang dipilih bukan clue awal
    if (_puzzle[_selectedCellIndex!] != 0) return;

    final int cellIndex = _selectedCellIndex!;

    setState(() {
      if (_isNotesMode) {
        // UC-11 Main Flow: toggle pencil mark.
        // Tidak boleh menambahkan notes ke sel yang sudah berisi angka final.
        if (_currentBoard[cellIndex] != 0) return;

        final Set<int> prevNotes = Set<int>.from(_notes[cellIndex]);
        if (_notes[cellIndex].contains(number)) {
          _notes[cellIndex].remove(number); // Step 5: toggle off
        } else {
          _notes[cellIndex].add(number); // Step 4: tambahkan ke notes
        }

        // Undo support: aksi notes-only — prevValue tidak berubah.
        _undoStack.add(GameAction(
          cellIndex: cellIndex,
          prevValue: 0,
          wasError: false,
          prevNotes: prevNotes,
        ));
      } else {
        final int previousValue = _currentBoard[cellIndex];
        final bool wasError = previousValue != 0 && previousValue != _solution[cellIndex];

        // Skip kalau angka yang sama ditekan lagi (no-op, jangan kotori undo stack)
        if (previousValue == number) return;

        // UC-08 Step 7: Push aksi ke undo stack SEBELUM state berubah.
        // Snapshot notes sel ini agar undo bisa restore (UC-11 catatan: clear-on-fill).
        _undoStack.add(GameAction(
          cellIndex: cellIndex,
          prevValue: previousValue,
          wasError: wasError,
          prevNotes: Set<int>.from(_notes[cellIndex]),
        ));

        // UC-08 Main Flow Step 5 & 6: Isi angka dan Validasi
        _currentBoard[cellIndex] = number;
        // UC-11 catatan: clear semua notes di sel yang baru diisi
        _notes[cellIndex].clear();
        // UC-11 QoL: auto-clean notes 'number' di related cells (row/col/box)
        _autoCleanRelatedNotes(cellIndex, number);

        if (_currentBoard[cellIndex] != _solution[cellIndex]) {
          // Salah: mistakes +1
          _mistakes++;

          // UC-08 - Alternate Flow A2: Mistakes mencapai 3
          if (_mistakes >= 3) {
            _handleGameOver();
          }
        } else {
          // Benar: Cek apakah board penuh (UC-13)
          _checkWinCondition();
        }
      }
    });

    // UC-08 Step 8 / UC-11: auto-save (debounced) untuk semua aksi cell.
    _scheduleAutoSave();
  }

  // UC-11 QoL: ketika sel diisi angka X, hapus pencil mark X dari sel lain
  // di baris, kolom, atau box yang sama.
  void _autoCleanRelatedNotes(int cellIndex, int number) {
    final int row = cellIndex ~/ 9;
    final int col = cellIndex % 9;
    final int boxRow = row ~/ 3;
    final int boxCol = col ~/ 3;
    for (int i = 0; i < 81; i++) {
      if (i == cellIndex) continue;
      if (!_notes[i].contains(number)) continue;
      final int r = i ~/ 9;
      final int c = i % 9;
      final bool related =
          r == row || c == col || (r ~/ 3 == boxRow && c ~/ 3 == boxCol);
      if (related) _notes[i].remove(number);
    }
  }

  // UC-12: Main Flow + A1
  void _handleHint() {
    final int remaining = _maxHints - _hintsUsed;
    if (remaining <= 0) return; // A1: quota habis → no-op (UI juga disabled)

    // Strategi: Option A (sel ter-select kalau kosong & bukan clue), fallback Option B (sel kosong pertama).
    int? target;
    final int? sel = _selectedCellIndex;
    if (sel != null && _puzzle[sel] == 0 && _currentBoard[sel] != _solution[sel]) {
      target = sel;
    } else {
      for (int i = 0; i < 81; i++) {
        if (_puzzle[i] == 0 && _currentBoard[i] != _solution[i]) {
          target = i;
          break;
        }
      }
    }
    if (target == null) return; // tidak ada sel yang bisa di-hint

    setState(() {
      _currentBoard[target!] = _solution[target];
      _notes[target].clear();
      _autoCleanRelatedNotes(target, _solution[target]);
      _hintsUsed++;
      _selectedCellIndex = target;
      // UC-12: aksi hint TIDAK masuk undo stack (sesuai rekomendasi spec)
    });

    _scheduleAutoSave();
    _checkWinCondition();
  }

  void _handleUndo() {
    if (_undoStack.isEmpty) return; // Alternate Flow A1: Undo stack kosong

    setState(() {
      // Pop aksi terakhir
      final lastAction = _undoStack.removeLast();

      // Kembalikan nilai cell ke state sebelumnya
      _currentBoard[lastAction.cellIndex] = lastAction.prevValue;
      // UC-11: restore notes snapshot
      _notes[lastAction.cellIndex]
        ..clear()
        ..addAll(lastAction.prevNotes);

      // Pindahkan seleksi ke cell yang baru saja di-undo (Opsional untuk UX yang baik)
      _selectedCellIndex = lastAction.cellIndex;

      // Catatan: _mistakes TIDAK di-decrement untuk mencegah abuse (Sesuai kesepakatan tim)
    });
    _scheduleAutoSave();
  }

  // UC-14: Trigger dari _onNumberPressed ketika _mistakes mencapai 3.
  Future<void> _handleGameOver() async {
    _stopTimer();
    await LocalStorageService.clearActiveGame();

    // Stats: games_played +1, current_streak reset (UC-14 step 4)
    final stats = await LocalStorageService.loadStats();
    await LocalStorageService.saveStats(stats.copyWith(
      gamesPlayed: stats.gamesPlayed + 1,
      currentStreak: 0,
    ));

    if (!mounted) return;

    final int filled = _puzzle
        .asMap()
        .entries
        .where((e) => e.value == 0 && _currentBoard[e.key] != 0)
        .length;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameOverModal(
        elapsedSeconds: _elapsedSeconds,
        filledCells: filled,
        onTryAgain: () {
          Navigator.of(ctx).pop();
          _resetForRetry();
        },
        onNewPuzzle: () {
          Navigator.of(ctx).pop();
          // TODO: UC-06 generate puzzle baru. Untuk MVP, sama dengan retry.
          _resetForRetry();
        },
        onBackHome: () {
          Navigator.of(ctx).pop();
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _resetForRetry() {
    setState(() {
      _currentBoard = List.from(_puzzle);
      for (final s in _notes) {
        s.clear();
      }
      _undoStack.clear();
      _selectedCellIndex = null;
      _mistakes = 0;
      _hintsUsed = 0;
      _elapsedSeconds = 0;
    });
    _startTimer();
  }

  // UC-13: dipanggil setelah setiap input benar (Step 1 trigger dari UC-08 Step 6).
  Future<void> _checkWinCondition() async {
    if (_mistakes >= 3) return;
    for (int i = 0; i < 81; i++) {
      if (_currentBoard[i] != _solution[i]) return;
    }

    _stopTimer(); // Step 2
    await LocalStorageService.clearActiveGame();

    const String difficulty = 'Medium'; // TODO: dari GameSession aktif
    final int score = _calculateScore(difficulty); // Step 3

    // Step 4–6: update stats, streak, personal best
    final PlayerStats stats = await LocalStorageService.loadStats();
    final int prevBest = stats.bestTimeFor(difficulty);
    final bool isNewBest = prevBest == 0 || _elapsedSeconds < prevBest;

    final String today = _todayKey();
    final String? lastWin = stats.lastWinDateIso;
    final int newStreak = _computeStreak(currentStreak: stats.currentStreak, lastWinIso: lastWin, todayIso: today);

    final Map<String, int> updatedBest =
        Map<String, int>.from(stats.bestTimeByDifficulty);
    if (isNewBest) updatedBest[difficulty] = _elapsedSeconds;

    final updated = stats.copyWith(
      gamesPlayed: stats.gamesPlayed + 1,
      gamesWon: stats.gamesWon + 1,
      currentStreak: newStreak,
      longestStreak:
          newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
      bestTimeByDifficulty: updatedBest,
      lastWinDateIso: today,
    );
    await LocalStorageService.saveStats(updated);

    // Step 8: kirim ke backend → TODO ketika API client tersedia.

    if (!mounted) return;

    // Step 7: tampilkan layar Game Completed
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameCompletedModal(
        difficulty: difficulty,
        level: 12, // TODO: dari GameSession aktif
        elapsedSeconds: _elapsedSeconds,
        score: score,
        isNewPersonalBest: isNewBest,
        previousBestSeconds: prevBest,
        streakDays: newStreak,
        onPlayNext: () {
          Navigator.of(context).pop();
          // TODO: UC-06 generate puzzle baru difficulty sama
          _resetForRetry();
        },
        onReviewGrid: () => Navigator.of(context).pop(),
        onShare: () {
          // TODO: UC-17 share result
        },
      ),
    ));
  }

  // UC-13 step 3: score = base - waktu*0.5 - mistakes*50 - hints*100 (clamp ≥ 0)
  int _calculateScore(String difficulty) {
    const Map<String, int> baseByDifficulty = {
      'Easy': 500,
      'Medium': 750,
      'Hard': 1000,
      'Expert': 1250,
      'Master': 1500,
    };
    final int base = baseByDifficulty[difficulty] ?? 500;
    final num raw = base - (_elapsedSeconds * 0.5) - (_mistakes * 50) - (_hintsUsed * 100);
    return raw < 0 ? 0 : raw.round();
  }

  String _todayKey() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}';
  }

  // Daily streak: +1 kalau menang berturut-turut tiap hari; reset jika lewat 1 hari.
  int _computeStreak({
    required int currentStreak,
    required String? lastWinIso,
    required String todayIso,
  }) {
    if (lastWinIso == null) return 1;
    if (lastWinIso == todayIso) return currentStreak == 0 ? 1 : currentStreak;
    final last = DateTime.parse(lastWinIso);
    final today = DateTime.parse(todayIso);
    final diff = today.difference(last).inDays;
    if (diff == 1) return currentStreak + 1;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF161622);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SUDOKU PRO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('MISTAKES: $_mistakes/3', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                Text(_formatTime(_elapsedSeconds), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Badges (Level, Difficulty, Streak)
            _buildBadges(),
            const SizedBox(height: 16),
            
            // Grid Sudoku (UC-08)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SudokuGrid(
                  puzzle: _puzzle,
                  currentBoard: _currentBoard,
                  solution: _solution,
                  notes: _notes,
                  selectedIndex: _selectedCellIndex,
                  onCellTapped: _onCellTapped,
                ),
              ),
            ),
            
            // Action Bar (Undo, Erase, Notes, Hint)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: ActionBar(
                isNotesActive: _isNotesMode,
                onNotesToggled: () => setState(() => _isNotesMode = !_isNotesMode),
                onErase: () {
                  if (_selectedCellIndex == null) return;
                  final idx = _selectedCellIndex!;
                  if (_puzzle[idx] != 0) return; // sel clue: read-only
                  final prev = _currentBoard[idx];
                  final prevNotes = Set<int>.from(_notes[idx]);
                  // Tidak ada yang dihapus → no-op
                  if (prev == 0 && prevNotes.isEmpty) return;
                  final wasError = prev != 0 && prev != _solution[idx];
                  setState(() {
                    _undoStack.add(GameAction(
                      cellIndex: idx,
                      prevValue: prev,
                      wasError: wasError,
                      prevNotes: prevNotes,
                    ));
                    _currentBoard[idx] = 0;
                    _notes[idx].clear();
                  });
                  _scheduleAutoSave();
                },
                onUndo: _handleUndo,
                canUndo: _undoStack.isNotEmpty,
                onHint: _handleHint,
                hintsRemaining: _maxHints - _hintsUsed,
              ),
            ),
            
            // Number Pad (1-9)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
              child: NumberPad(onNumberPressed: _onNumberPressed),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 16),
        _badge('LEVEL 12', Colors.grey[800]!, Colors.grey[400]!),
        const SizedBox(width: 8),
        _badge('MEDIUM', Colors.orange[900]!.withOpacity(0.5), Colors.orange),
        const SizedBox(width: 8),
        _badge('3X STREAK', Colors.orange[900]!.withOpacity(0.5), Colors.orange),
      ],
    );
  }

  Widget _badge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}