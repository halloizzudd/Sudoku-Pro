import 'dart:convert';

class GameSession {
  final String id;
  final String difficulty;
  final int level;
  final List<int> puzzle;
  final List<int> solution; // UC-07: wajib agar validasi tetap jalan saat resume
  final List<int> currentBoard;
  final List<List<int>> notes; // UC-11: pencil mark per sel (disimpan agar resume utuh)
  final int mistakes;
  final int hintsUsed;
  final int elapsedSeconds;

  GameSession({
    required this.id,
    required this.difficulty,
    this.level = 1,
    required this.puzzle,
    required this.solution,
    required this.currentBoard,
    this.notes = const [],
    required this.mistakes,
    required this.hintsUsed,
    required this.elapsedSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'difficulty': difficulty,
      'level': level,
      'puzzle': puzzle,
      'solution': solution,
      'currentBoard': currentBoard,
      'notes': notes,
      'mistakes': mistakes,
      'hintsUsed': hintsUsed,
      'elapsedSeconds': elapsedSeconds,
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      level: map['level']?.toInt() ?? 1,
      puzzle: List<int>.from(map['puzzle']),
      solution: List<int>.from(map['solution'] ?? const []),
      currentBoard: List<int>.from(map['currentBoard']),
      notes: (map['notes'] as List?)
              ?.map((e) => List<int>.from(e as List))
              .toList() ??
          const [],
      mistakes: map['mistakes']?.toInt() ?? 0,
      hintsUsed: map['hintsUsed']?.toInt() ?? 0,
      elapsedSeconds: map['elapsedSeconds']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameSession.fromJson(String source) => GameSession.fromMap(json.decode(source));
}
