class GameAction {
  final int cellIndex;
  final int prevValue;
  final bool wasError;
  // UC-11: snapshot notes sel sebelum aksi, agar undo bisa restore pencil marks.
  // Untuk aksi notes-only: prevValue == newValue (== 0 biasanya).
  final Set<int> prevNotes;

  GameAction({
    required this.cellIndex,
    required this.prevValue,
    required this.wasError,
    Set<int>? prevNotes,
  }) : prevNotes = prevNotes ?? const <int>{};
}