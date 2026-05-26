import 'package:flutter/material.dart';

// UC-04: dialog loading saat menautkan akun SSO.
class LinkingDialog extends StatelessWidget {
  const LinkingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Color(0xFF5C4EE5)),
            ),
            SizedBox(width: 18),
            Text('Linking account...',
                style: TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
