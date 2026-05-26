import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// Layar Privacy & Security (dirujuk dari menu Profile UC-19). Item membuka
// dialog placeholder berisi teks dummy sampai fitur masing-masing diimplementasi
// — tidak ada tombol yang "diam" saat ditekan.
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
        title: Text('PRIVACY & SECURITY',
            style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _sectionLabel(c, 'ACCOUNT'),
          _item(context, c,
              icon: Icons.vpn_key_outlined,
              label: 'Change Password',
              body:
                  'Security Settings\n\nYou can update your password here. For now this '
                  'is a placeholder — choose a strong password with at least 8 '
                  'characters, mixing letters, numbers, and symbols.'),
          _item(context, c,
              icon: Icons.shield_outlined,
              label: 'Two-Factor Authentication',
              trailing: _badge(c, 'Enabled'),
              body:
                  'Security Settings\n\nTwo-factor authentication adds an extra layer '
                  'of protection to your account by requiring a one-time code in '
                  'addition to your password.'),
          _item(context, c,
              icon: Icons.history,
              label: 'Login Activity',
              body:
                  'Security Settings\n\nReview recent sign-ins to your account, '
                  'including device, location, and time. No suspicious activity '
                  'has been detected.'),
          const SizedBox(height: 20),
          _sectionLabel(c, 'DATA'),
          _item(context, c,
              icon: Icons.download_outlined,
              label: 'Download My Data',
              body:
                  'Privacy\n\nRequest a copy of the data associated with your '
                  'account. When ready, a download link will be sent to your '
                  'registered email address.'),
          _item(context, c,
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              trailing:
                  Icon(Icons.open_in_new, color: c.textSecondary, size: 18),
              body:
                  'Privacy Policy\n\nWe respect your privacy. Sudoku Pro stores your '
                  'game progress and statistics locally on your device. We do not '
                  'sell your personal data to third parties. This is placeholder '
                  'text for demonstration purposes.'),
          const SizedBox(height: 20),
          _sectionLabel(c, 'DANGER ZONE', color: c.danger),
          _item(context, c,
              icon: Icons.delete_outline,
              label: 'Account Deletion',
              danger: true,
              body:
                  'Privacy\n\nPermanently delete your account and all associated '
                  'data. This action cannot be undone. This is a placeholder — no '
                  'data will actually be removed.'),
        ],
      ),
    );
  }

  Widget _sectionLabel(AppColors c, String text, {Color? color}) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4, top: 4),
        child: Text(text,
            style: TextStyle(
                color: color ?? c.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8)),
      );

  Widget _item(
    BuildContext context,
    AppColors c, {
    required IconData icon,
    required String label,
    required String body,
    Widget? trailing,
    bool danger = false,
  }) {
    final color = danger ? c.danger : c.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: danger ? c.danger.withOpacity(0.08) : c.surface,
        borderRadius: BorderRadius.circular(14),
        border: danger ? Border.all(color: c.danger.withOpacity(0.4)) : null,
      ),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: danger ? c.danger : c.textPrimary),
        title: Text(label,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: trailing ??
            Icon(Icons.chevron_right,
                color: danger ? c.danger : c.textSecondary),
        onTap: () => _showPlaceholder(context, c, label, body),
      ),
    );
  }

  // Placeholder dialog dengan teks dummy — memastikan setiap item dapat ditekan.
  void _showPlaceholder(
      BuildContext context, AppColors c, String title, String body) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title,
            style: TextStyle(
                color: c.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(body,
            style: TextStyle(color: c.textSecondary, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CLOSE',
                style: TextStyle(
                    color: c.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _badge(AppColors c, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: c.primary.withOpacity(0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                color: c.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}
