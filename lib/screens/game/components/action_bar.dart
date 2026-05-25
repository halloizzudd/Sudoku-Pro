import 'package:flutter/material.dart';

class ActionBar extends StatelessWidget {
  final bool isNotesActive;
  final VoidCallback onNotesToggled;
  final VoidCallback onErase;
  final VoidCallback onUndo;
  final bool canUndo;
  final VoidCallback onHint;
  final int hintsRemaining; // UC-12: quota tampil di badge, 0 → disabled

  const ActionBar({
    super.key,
    required this.isNotesActive,
    required this.onNotesToggled,
    required this.onErase,
    required this.onUndo,
    required this.canUndo,
    required this.onHint,
    required this.hintsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(
          Icons.undo,
          'UNDO',
          canUndo ? onUndo : () {}, // UC-10 A1: no-op jika stack kosong
          isDisabled: !canUndo,
        ),
        _actionButton(Icons.backspace_outlined, 'ERASE', onErase),
        _actionButton(
          Icons.edit,
          'NOTES',
          onNotesToggled,
          isActive: isNotesActive,
        ),
        _actionButton(
          Icons.lightbulb_outline,
          'HINT',
          hintsRemaining > 0 ? onHint : () {}, // UC-12 A1: no-op kalau quota habis
          badge: hintsRemaining > 0 ? '$hintsRemaining' : null,
          accentColor: Colors.orange,
          isDisabled: hintsRemaining <= 0,
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap,
      {bool isActive = false, bool isDisabled = false, String? badge, Color? accentColor}) {

    Color activeColor = accentColor ?? const Color(0xFF5C4EE5);
    Color defaultColor = isDisabled ? const Color(0xFF3A3A5A) : Colors.grey;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isActive ? activeColor.withOpacity(0.2) : Colors.transparent,
                  border: Border.all(color: isActive ? activeColor : const Color(0xFF3A3A5A)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isActive ? activeColor : defaultColor, size: 24),
              ),
              if (badge != null)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isActive ? activeColor : defaultColor, fontSize: 10)),
        ],
      ),
    );
  }
}