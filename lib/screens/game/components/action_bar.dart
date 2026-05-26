import 'package:flutter/material.dart';
import '../../../services/l10n.dart';
import '../../../theme/app_colors.dart';

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
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(
          c,
          Icons.undo,
          L10n.t('undo'),
          canUndo ? onUndo : () {}, // UC-10 A1: no-op jika stack kosong
          isDisabled: !canUndo,
        ),
        _actionButton(c, Icons.backspace_outlined, L10n.t('erase'), onErase),
        _actionButton(
          c,
          Icons.edit,
          L10n.t('notes'),
          onNotesToggled,
          isActive: isNotesActive,
        ),
        _actionButton(
          c,
          Icons.lightbulb_outline,
          L10n.t('hint'),
          hintsRemaining > 0 ? onHint : () {}, // UC-12 A1: no-op kalau quota habis
          badge: hintsRemaining > 0 ? '$hintsRemaining' : null,
          accentColor: c.accent,
          isDisabled: hintsRemaining <= 0,
        ),
      ],
    );
  }

  Widget _actionButton(AppColors c, IconData icon, String label, VoidCallback onTap,
      {bool isActive = false, bool isDisabled = false, String? badge, Color? accentColor}) {

    Color activeColor = accentColor ?? c.primary;
    Color defaultColor = isDisabled ? c.gridLine : c.textSecondary;

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
                  border: Border.all(color: isActive ? activeColor : c.gridLine),
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
                    decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
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