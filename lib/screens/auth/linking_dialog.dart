import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// UC-04: dialog loading saat menautkan akun SSO.
class LinkingDialog extends StatelessWidget {
  const LinkingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: c.primary),
            ),
            const SizedBox(width: 18),
            Text('Linking account...',
                style: TextStyle(color: c.textPrimary, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
