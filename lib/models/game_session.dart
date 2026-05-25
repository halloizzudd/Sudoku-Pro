import 'dart:convert';

class GameSession {
  final String id;
  final String difficulty;
  final List<int> puzzle;
  final List<int> currentBoard;
  final int mistakes;
  final int hintsUsed;
  final int elapsedSeconds;
  
  // Catatan: notes dan undoStack disederhanakan dulu untuk MVP
  // Di implementasi penuh, notes bisa berupa List<List<int>>

  GameSession({
    required this.id,
    required this.difficulty,
    required this.puzzle,
    required this.currentBoard,
    required this.mistakes,
    required this.hintsUsed,
    required this.elapsedSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'difficulty': difficulty,
      'puzzle': puzzle,
      'currentBoard': currentBoard,
      'mistakes': mistakes,
      'hintsUsed': hintsUsed,
      'elapsedSeconds': elapsedSeconds,
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      puzzle: List<int>.from(map['puzzle']),
      currentBoard: List<int>.from(map['currentBoard']),
      mistakes: map['mistakes']?.toInt() ?? 0,
      hintsUsed: map['hintsUsed']?.toInt() ?? 0,
      elapsedSeconds: map['elapsedSeconds']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameSession.fromJson(String source) => GameSession.fromMap(json.decode(source));
}