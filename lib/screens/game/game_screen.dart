import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/game_action.dart';
import '../../models/game_session.dart';
import '../../models/player_stats.dart';
import '../../services/local_storage_service.dart';
import '../../services/sudoku_generator.dart';
import '../../services/share_service.dart';
import '../../services/leaderboard_service.dart';
import '../../services/l10n.dart';
import '../../theme/app_colors.dart';
import 'game_completed_modal.dart';
import 'game_over_modal.dart';
import 'components/sudoku_grid.dart';
import 'components/number_pad.dart';
import 'components/action_bar.dart';

// UC-06/07/08/13/14: layar permainan. Menerima difficulty + level dari Home,
// atau melanjutkan game tersimpan lewat [resumeSession] (UC-07).
class GameScreen extends StatefulWidget {
  final String difficulty;
  final int level;
  final GameSession? resumeSession;

  const GameScreen({
    super.key,
    this.difficulty = 'Medium',
    this.level = 1,
    this.resumeSession,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // 0 = sel kosong.
  late List<int> _puzzle; // clue awal
  late List<int> _solution; // solusi penuh (untuk validasi UC-08)
  late List<int> _currentBoard;
  late List<Set<int>> _notes; // UC-11: pencil mark per sel

  static const int _maxHints = 3; // UC-12: quota default

  int? _selectedCellIndex;
  int _mistakes = 0;
  int _hintsUsed = 0;
  int _elapsedSeconds = 0;
  bool _isNotesMode = false;
  bool _isPaused = false; // GAP-04
  bool _loading = true; // true saat generate puzzle (UC-06)
  int _streak = 0; // badge streak (dari stats)
  late String _sessionId;

  final List<GameAction> _undoStack = [];
  Timer? _saveDebounce;
  Timer? _gameTimer;
  late AppColors c; // diisi di build, dipakai helper

  // Task 3: konfirmasi keluar saat sedang main (progress tetap tersimpan).
  Future<bool> _confirmLeave() async {
    if (_loading) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Leave game?', style: TextStyle(color: c.textPrimary)),
        content: Text(
          'Are you sure you want to leave? Your progress will be saved.',
          style: TextStyle(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('NO', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('YES', style: TextStyle(color: c.primary)),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  void initState() {
    super.initState();
    _loadStreakBadge();
    final resume = widget.resumeSession;
    if (resume != null) {
      _restoreFrom(resume); // UC-07
    } else {
      _puzzle = List<int>.filled(81, 0);
      _solution = List<int>.filled(81, 0);
      _currentBoard = List<int>.filled(81, 0);
      _notes = List.generate(81, (_) => <int>{});
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _newPuzzle(); // UC-06
    }
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStreakBadge() async {
    final s = await LocalStorageService.loadStats();
    if (!mounted) return;
    setState(() => _streak = s.currentStreak);
  }

  // UC-06: generate puzzle baru sesuai difficulty (di isolate via compute).
  Future<void> _newPuzzle() async {
    setState(() => _loading = true);
    final p = await SudokuGenerator.generate(widget.difficulty);
    if (!mounted) return;
    setState(() {
      _puzzle = p.puzzle;
      _solution = p.solution;
      _currentBoard = List<int>.of(p.puzzle);
      _notes = List.generate(81, (_) => <int>{});
      _undoStack.clear();
      _selectedCellIndex = null;
      _mistakes = 0;
      _hintsUsed = 0;
      _elapsedSeconds = 0;
      _isPaused = false;
      _loading = false;
    });
    _startTimer();
    _scheduleAutoSave();
  }

  // UC-07: restore state dari saved session.
  void _restoreFrom(GameSession s) {
    _sessionId = s.id;
    _puzzle = List<int>.of(s.puzzle);
    _solution = s.solution.length == 81
        ? List<int>.of(s.solution)
        : List<int>.filled(81, 0);
    _currentBoard = List<int>.of(s.currentBoard);
    _notes = List.generate(
        81, (i) => i < s.notes.length ? s.notes[i].toSet() : <int>{});
    _mistakes = s.mistakes;
    _hintsUsed = s.hintsUsed;
    _elapsedSeconds = s.elapsedSeconds;
    _loading = false;
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused) return;
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

  // UC-08 Step 8: auto-save debounced agar tidak hit storage tiap tap.
  void _scheduleAutoSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      LocalStorageService.saveGameSession(GameSession(
        id: _sessionId,
        difficulty: widget.difficulty,
        level: widget.level,
        puzzle: _puzzle,
        solution: _solution,
        currentBoard: _currentBoard,
        notes: _notes.map((s) => s.toList()).toList(),
        mistakes: _mistakes,
        hintsUsed: _hintsUsed,
        elapsedSeconds: _elapsedSeconds,
      ));
    });
  }

  // --- LOGIKA UC-08 ---

  void _onCellTapped(int index) {
    if (_isPaused) return;
    if (_puzzle[index] != 0) return; // A1: clue awal read-only
    setState(() => _selectedCellIndex = index);
  }

  void _onNumberPressed(int number) {
    if (_isPaused) return;
    if (_selectedCellIndex == null) return;
    if (_puzzle[_selectedCellIndex!] != 0) return;

    final int cellIndex = _selectedCellIndex!;

    setState(() {
      if (_isNotesMode) {
        // UC-11: toggle pencil mark.
        if (_currentBoard[cellIndex] != 0) return;
        final Set<int> prevNotes = Set<int>.from(_notes[cellIndex]);
        if (_notes[cellIndex].contains(number)) {
          _notes[cellIndex].remove(number);
        } else {
          _notes[cellIndex].add(number);
        }
        _undoStack.add(GameAction(
          cellIndex: cellIndex,
          prevValue: 0,
          wasError: false,
          prevNotes: prevNotes,
        ));
      } else {
        final int previousValue = _currentBoard[cellIndex];
        final bool wasError =
            previousValue != 0 && previousValue != _solution[cellIndex];
        if (previousValue == number) return; // no-op

        _undoStack.add(GameAction(
          cellIndex: cellIndex,
          prevValue: previousValue,
          wasError: wasError,
          prevNotes: Set<int>.from(_notes[cellIndex]),
        ));

        _currentBoard[cellIndex] = number;
        _notes[cellIndex].clear();
        _autoCleanRelatedNotes(cellIndex, number);

        if (_currentBoard[cellIndex] != _solution[cellIndex]) {
          _mistakes++;
          if (_mistakes >= 3) _handleGameOver(); // A2 → UC-14
        } else {
          _checkWinCondition(); // UC-13
        }
      }
    });

    _scheduleAutoSave();
  }

  // UC-11 QoL: hapus pencil mark X dari sel di baris/kolom/box sama.
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
    if (_isPaused) return;
    final int remaining = _maxHints - _hintsUsed;
    if (remaining <= 0) return;

    int? target;
    final int? sel = _selectedCellIndex;
    if (sel != null &&
        _puzzle[sel] == 0 &&
        _currentBoard[sel] != _solution[sel]) {
      target = sel;
    } else {
      for (int i = 0; i < 81; i++) {
        if (_puzzle[i] == 0 && _currentBoard[i] != _solution[i]) {
          target = i;
          break;
        }
      }
    }
    if (target == null) return;

    setState(() {
      _currentBoard[target!] = _solution[target];
      _notes[target].clear();
      _autoCleanRelatedNotes(target, _solution[target]);
      _hintsUsed++;
      _selectedCellIndex = target;
    });

    _scheduleAutoSave();
    _checkWinCondition();
  }

  void _handleUndo() {
    if (_isPaused) return;
    if (_undoStack.isEmpty) return; // A1

    setState(() {
      final lastAction = _undoStack.removeLast();
      _currentBoard[lastAction.cellIndex] = lastAction.prevValue;
      _notes[lastAction.cellIndex]
        ..clear()
        ..addAll(lastAction.prevNotes);
      _selectedCellIndex = lastAction.cellIndex;
      // _mistakes sengaja tidak di-decrement (anti-abuse).
    });
    _scheduleAutoSave();
  }

  // UC-14: dipicu saat _mistakes mencapai 3.
  Future<void> _handleGameOver() async {
    _stopTimer();
    await LocalStorageService.clearActiveGame();

    final stats = await LocalStorageService.loadStats();
    await LocalStorageService.saveStats(stats.copyWith(
      gamesPlayed: stats.gamesPlayed + 1,
      currentStreak: 0, // kalah memutus streak
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
          _newPuzzle(); // UC-06: puzzle baru difficulty sama
        },
        onBackHome: () {
          Navigator.of(ctx).pop();
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
        onShare: () => ShareService.shareGameOver(
          elapsedSeconds: _elapsedSeconds,
          filledCells: filled,
        ),
      ),
    );
  }

  // Try Again: pakai puzzle yang sama, reset progress.
  void _resetForRetry() {
    setState(() {
      _currentBoard = List<int>.of(_puzzle);
      for (final s in _notes) {
        s.clear();
      }
      _undoStack.clear();
      _selectedCellIndex = null;
      _mistakes = 0;
      _hintsUsed = 0;
      _elapsedSeconds = 0;
      _isPaused = false;
    });
    _startTimer();
    _scheduleAutoSave();
  }

  // UC-13: dicek setelah tiap input benar.
  Future<void> _checkWinCondition() async {
    if (_mistakes >= 3) return;
    for (int i = 0; i < 81; i++) {
      if (_currentBoard[i] != _solution[i]) return;
    }

    _stopTimer();
    await LocalStorageService.clearActiveGame();

    final String difficulty = widget.difficulty;
    final int score = _calculateScore(difficulty);

    // UC-15: submit skor ke backend (stub log untuk MVP).
    LeaderboardService.submitScoreToServer(score, difficulty);

    final PlayerStats stats = await LocalStorageService.loadStats();
    final int prevBest = stats.bestTimeFor(difficulty);
    final bool isNewBest = prevBest == 0 || _elapsedSeconds < prevBest;

    final String today = _todayKey();
    final int newStreak = _computeStreak(
        currentStreak: stats.currentStreak,
        lastWinIso: stats.lastWinDateIso,
        todayIso: today);

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

    // Step 8: kirim ke backend → TODO saat API client tersedia.

    if (!mounted) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameCompletedModal(
        difficulty: difficulty,
        level: widget.level,
        elapsedSeconds: _elapsedSeconds,
        score: score,
        isNewPersonalBest: isNewBest,
        previousBestSeconds: prevBest,
        streakDays: newStreak,
        onPlayNext: () {
          Navigator.of(context).pop();
          _newPuzzle(); // UC-06 difficulty sama
        },
        onReviewGrid: () => Navigator.of(context).pop(),
        onShare: () => ShareService.shareResult(
          difficulty: difficulty,
          elapsedSeconds: _elapsedSeconds,
          score: score,
        ),
      ),
    ));
  }

  // UC-13: score = base - waktu*0.5 - mistakes*50 - hints*100 (clamp ≥ 0)
  int _calculateScore(String difficulty) {
    const Map<String, int> baseByDifficulty = {
      'Easy': 500,
      'Medium': 750,
      'Hard': 1000,
      'Expert': 1250,
      'Master': 1500,
    };
    final int base = baseByDifficulty[difficulty] ?? 500;
    final num raw =
        base - (_elapsedSeconds * 0.5) - (_mistakes * 50) - (_hintsUsed * 100);
    return raw < 0 ? 0 : raw.round();
  }

  String _todayKey() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}';
  }

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

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  @override
  Widget build(BuildContext context) {
    c = context.colors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: c.textPrimary, size: 20),
          onPressed: () async {
            if (await _confirmLeave() && mounted) Navigator.of(context).pop();
          },
        ),
        title: Text(
          'SUDOKU PRO',
          style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${L10n.t('mistakes')}: $_mistakes/3',
                    style: TextStyle(color: c.textSecondary, fontSize: 10)),
                Text(_formatTime(_elapsedSeconds),
                    style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // GAP-04: tombol pause (disabled saat loading).
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause,
                color: c.textPrimary),
            onPressed: _loading ? null : _togglePause,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: c.primary),
                  const SizedBox(height: 16),
                  Text(L10n.t('generatingPuzzle'),
                      style: TextStyle(color: c.textSecondary)),
                ],
              ),
            )
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildBadges(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        child: ActionBar(
                          isNotesActive: _isNotesMode,
                          onNotesToggled: () =>
                              setState(() => _isNotesMode = !_isNotesMode),
                          onErase: _handleErase,
                          onUndo: _handleUndo,
                          canUndo: _undoStack.isNotEmpty,
                          onHint: _handleHint,
                          hintsRemaining: _maxHints - _hintsUsed,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 24.0, left: 16.0, right: 16.0),
                        child:
                            NumberPad(onNumberPressed: _onNumberPressed),
                      ),
                    ],
                  ),
                  if (_isPaused) _buildPauseOverlay(),
                ],
              ),
            ),
      ),
    );
  }

  void _handleErase() {
    if (_isPaused) return;
    if (_selectedCellIndex == null) return;
    final idx = _selectedCellIndex!;
    if (_puzzle[idx] != 0) return; // clue read-only
    final prev = _currentBoard[idx];
    final prevNotes = Set<int>.from(_notes[idx]);
    if (prev == 0 && prevNotes.isEmpty) return; // no-op
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
  }

  // GAP-04: overlay pause — timer berhenti, board tertutup.
  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: Container(
        color: c.background.withOpacity(0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause_circle_outline, color: c.primary, size: 64),
              const SizedBox(height: 16),
              Text(L10n.t('paused'),
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_formatTime(_elapsedSeconds),
                  style: TextStyle(color: c.textSecondary, fontSize: 16)),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _togglePause,
                  icon: const Icon(Icons.play_arrow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  label: Text(L10n.t('resume'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadges() {
    // Scroll horizontal agar tidak overflow di layar sempit.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 16),
          _badge('LEVEL ${widget.level}', c.surface2, c.textSecondary),
          const SizedBox(width: 8),
          _badge(widget.difficulty.toUpperCase(),
              c.accent.withOpacity(0.15), c.accent),
          if (_streak > 0) ...[
            const SizedBox(width: 8),
            _badge('${_streak}X STREAK', c.accent.withOpacity(0.15), c.accent),
          ],
          const SizedBox(width: 16),
        ],
      ),
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
      child: Text(text,
          style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }
}
