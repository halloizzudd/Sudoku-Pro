import 'package:flutter/material.dart';

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
    // Mengecek apakah sel berada di baris, kolom, atau blok 3x3 yang sama dengan sel yang dipilih
    int row = index ~/ 9;
    int col = index % 9;
    int selRow = selected ~/ 9;
    int selCol = selected % 9;

    bool sameRow = row == selRow;
    bool sameCol = col == selCol;
    bool sameBox = (row ~/ 3 == selRow ~/ 3) && (col ~/ 3 == selCol ~/ 3);

    return sameRow || sameCol || sameBox;
  }

  // UC-08 Alternate Flow A3: Sel dianggap conflict jika nilainya (non-zero)
  // muncul juga di sel lain pada baris/kolom/box yang sama.
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3A3A5A), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF1E1E2E),
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
            bool isRelated = selectedIndex != null && _isRelatedCell(index, selectedIndex!);
            bool isError = value != 0 && !isFixed && value != solution[index];
            // A3: sel duplikat (cocok dengan sel lain di row/col/box) — UX cue
            bool isConflict = !isFixed && _hasConflict(index);
            // Same-value highlight: cell dengan value yang sama dengan cell terpilih
            bool isSameValue = !isSelected &&
                selectedIndex != null &&
                value != 0 &&
                currentBoard[selectedIndex!] == value;

            // Konfigurasi Warna berdasarkan state UC-08
            Color cellColor = Colors.transparent;
            if (isSelected) {
              cellColor = const Color(0xFF5C4EE5).withOpacity(0.5); // Biru highlight
            } else if (isConflict) {
              cellColor = const Color(0xFFE53935).withOpacity(0.18); // A3 conflict tint
            } else if (isSameValue) {
              cellColor = const Color(0xFF5C4EE5).withOpacity(0.18);
            } else if (isRelated) {
              cellColor = const Color(0xFF2A2A4A); // Highlight baris/kolom/box
            }

            Color textColor = Colors.white;
            if (isFixed) {
              textColor = Colors.grey[400]!;
            } else if (isError || isConflict) {
              textColor = Colors.redAccent;
            } else if (value != 0) {
              textColor = const Color(0xFF5C4EE5); // Warna angka input player (Benar)
            }

            // Logika Border 3x3 (Tebal untuk pemisah blok 3x3)
            int row = index ~/ 9;
            int col = index % 9;
            Border border = Border(
              bottom: BorderSide(color: const Color(0xFF3A3A5A), width: (row % 3 == 2 && row != 8) ? 2 : 0.5),
              right: BorderSide(color: const Color(0xFF3A3A5A), width: (col % 3 == 2 && col != 8) ? 2 : 0.5),
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
                            fontWeight: isFixed ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      )
                    : (cellNotes.isEmpty
                        ? const SizedBox.shrink()
                        : _NotesGrid(notes: cellNotes)),
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
  const _NotesGrid({required this.notes});

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
              style: const TextStyle(
                color: Color(0xFFB0B0C0),
                fontSize: 8,
                height: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}