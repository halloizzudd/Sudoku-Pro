import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SudokuGrid extends StatelessWidget {
  final List<int> puzzle;
  final List<int> currentBoard;
  final List<int> solution;
  final List<Set<int>> notes; // UC-11: pencil marks per sel
  final int? selectedIndex;
  final Function(int) onCellTapped;

  const SudokuGrid({
    super.key,
    required this.puzzle,
    required this.currentBoard,
    required this.solution,
    required this.notes,
    required this.selectedIndex,
    required this.onCellTapped,
  });

  bool _isRelatedCell(int index, int selected) {
    int row = index ~/ 9;
    int col = index % 9;
    int selRow = selected ~/ 9;
    int selCol = selected % 9;

    bool sameRow = row == selRow;
    bool sameCol = col == selCol;
    bool sameBox = (row ~/ 3 == selRow ~/ 3) && (col ~/ 3 == selCol ~/ 3);

    return sameRow || sameCol || sameBox;
  }

  // UC-08 Alternate Flow A3: konflik jika nilai (non-zero) muncul lagi
  // di baris/kolom/box yang sama.
  bool _hasConflict(int index) {
    final int value = currentBoard[index];
    if (value == 0) return false;
    final int row = index ~/ 9;
    final int col = index % 9;
    final int boxRow = row ~/ 3;
    final int boxCol = col ~/ 3;
    for (int i = 0; i < 81; i++) {
      if (i == index) continue;
      if (currentBoard[i] != value) continue;
      final int r = i ~/ 9;
      final int c = i % 9;
      final bool sameRow = r == row;
      final bool sameCol = c == col;
      final bool sameBox = (r ~/ 3 == boxRow) && (c ~/ 3 == boxCol);
      if (sameRow || sameCol || sameBox) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.gridLine, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: c.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 81,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemBuilder: (context, index) {
            int value = currentBoard[index];
            bool isFixed = puzzle[index] != 0;
            bool isSelected = selectedIndex == index;
            bool isRelated =
                selectedIndex != null && _isRelatedCell(index, selectedIndex!);
            bool isError = value != 0 && !isFixed && value != solution[index];
            bool isConflict = !isFixed && _hasConflict(index);
            bool isSameValue = !isSelected &&
                selectedIndex != null &&
                value != 0 &&
                currentBoard[selectedIndex!] == value;

            // Warna sel berdasarkan state (UC-08), reaktif terhadap tema.
            Color cellColor = Colors.transparent;
            if (isSelected) {
              cellColor = c.cellSelected;
            } else if (isConflict) {
              cellColor = c.danger.withOpacity(0.18);
            } else if (isSameValue) {
              cellColor = c.primary.withOpacity(0.18);
            } else if (isRelated) {
              cellColor = c.cellRelated;
            }

            Color textColor = c.textPrimary;
            if (isFixed) {
              textColor = c.textSecondary;
            } else if (isError || isConflict) {
              textColor = c.danger;
            } else if (value != 0) {
              textColor = c.primary; // angka input player (benar)
            }

            int row = index ~/ 9;
            int col = index % 9;
            Border border = Border(
              bottom: BorderSide(
                  color: c.gridLine,
                  width: (row % 3 == 2 && row != 8) ? 2 : 0.5),
              right: BorderSide(
                  color: c.gridLine,
                  width: (col % 3 == 2 && col != 8) ? 2 : 0.5),
            );

            final Set<int> cellNotes = notes[index];

            return GestureDetector(
              onTap: () => onCellTapped(index),
              child: Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  border: border,
                ),
                child: value != 0
                    ? Center(
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight:
                                isFixed ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      )
                    : (cellNotes.isEmpty
                        ? const SizedBox.shrink()
                        : _NotesGrid(notes: cellNotes, color: c.cellNote)),
              ),
            );
          },
        ),
      ),
    );
  }
}

// UC-11: render notes sebagai mini-grid 3x3 di dalam sel.
class _NotesGrid extends StatelessWidget {
  final Set<int> notes;
  final Color color;
  const _NotesGrid({required this.notes, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, i) {
          final int n = i + 1;
          final bool show = notes.contains(n);
          return Center(
            child: Text(
              show ? '$n' : '',
              style: TextStyle(color: color, fontSize: 8, height: 1),
            ),
          );
        },
      ),
    );
  }
}
