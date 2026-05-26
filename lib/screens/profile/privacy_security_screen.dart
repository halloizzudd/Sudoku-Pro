import 'package:flutter/material.dart';

// Layar Privacy & Security (dirujuk dari menu Profile UC-19). Sebagian besar
// item navigasional / placeholder sampai fitur masing-masing diimplementasi.
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  static const Color _bg = Color(0xFF0F0F1A);
  static const Color _card = Color(0xFF1A1A2E);
  static const Color _indigo = Color(0xFF5C4EE5);
  static const Color _danger = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('PRIVACY & SECURITY',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _sectionLabel('ACCOUNT'),
          _item(context,
              icon: Icons.vpn_key_outlined, label: 'Change Password'),
          _item(context,
              icon: Icons.shield_outlined,
              label: 'Two-Factor Authentication',
              trailing: _badge('Enabled')),
          _item(context, icon: Icons.history, label: 'Login Activity'),
          const SizedBox(height: 20),
          _sectionLabel('DATA'),
          _item(context,
              icon: Icons.download_outlined, label: 'Download My Data'),
          _item(context,
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              trailing: const Icon(Icons.open_in_new,
                  color: Colors.grey, size: 18)),
          const SizedBox(height: 20),
          _sectionLabel('DANGER ZONE', color: _danger),
          _item(context,
              icon: Icons.delete_outline,
              label: 'Account Deletion',
              danger: true),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {Color color = Colors.grey}) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4, top: 4),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8)),
      );

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? trailing,
    bool danger = false,
  }) {
    final color = danger ? _danger : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: danger ? _danger.withOpacity(0.08) : _card,
        borderRadius: BorderRadius.circular(14),
        border: danger
            ? Border.all(color: _danger.withOpacity(0.4))
            : null,
      ),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: danger ? _danger : Colors.white),
        title: Text(label,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: trailing ??
            Icon(Icons.chevron_right, color: danger ? _danger : Colors.grey),
        onTap: () {
          // TODO: implementasi masing-masing aksi (UC terkait).
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label — coming soon')),
          );
        },
      ),
    );
  }

  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _indigo.withOpacity(0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFFB0A6FF),
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}
