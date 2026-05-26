import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/settings_service.dart';

// UC-20: Edit Profile — upload avatar, ubah username, ubah email (re-verify),
// ubah password. Persist via SettingsService (TODO: PATCH /users/me).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _bg = Color(0xFF0F0F1A);
  static const Color _card = Color(0xFF1A1A2E);
  static const Color _indigo = Color(0xFF5C4EE5);
  static const Color _hint = Colors.grey;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _email;
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  late String _originalEmail;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = SettingsService.profile.value;
    _username = TextEditingController(text: p.username);
    _email = TextEditingController(text: p.email);
    _originalEmail = p.email;
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final emailChanged = _email.text.trim() != _originalEmail;
    final current = SettingsService.profile.value;
    final updated = current.copyWith(
      username: _username.text.trim(),
      email: _email.text.trim(),
    );
    await SettingsService.updateProfile(updated);

    // TODO UC-20: jika password diisi → PATCH /users/me/password.
    if (!mounted) return;
    setState(() => _saving = false);

    final msg = emailChanged
        ? 'Profile saved. Check your inbox to re-verify the new email.'
        : 'Profile saved.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('EDIT PROFILE',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _avatarPicker(),
            const SizedBox(height: 28),
            _label('USERNAME'),
            _field(
              controller: _username,
              hint: 'your username',
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Username cannot be empty'
                  : null,
            ),
            const SizedBox(height: 20),
            _label('EMAIL ADDRESS'),
            _field(
              controller: _email,
              hint: 'your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email cannot be empty';
                }
                final re = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!re.hasMatch(v.trim())) return 'Invalid email format';
                return null;
              },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text('Changing your email requires re-verification.',
                  style: TextStyle(color: _hint, fontSize: 11)),
            ),
            const SizedBox(height: 28),
            const Text('CHANGE PASSWORD',
                style: TextStyle(
                    color: _hint,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _label('NEW PASSWORD'),
            _field(
              controller: _newPassword,
              hint: 'leave blank to keep current',
              icon: Icons.lock_outline,
              obscure: true,
              validator: (v) {
                if (v == null || v.isEmpty) return null; // opsional
                if (v.length < 8) return 'At least 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _label('CONFIRM NEW PASSWORD'),
            _field(
              controller: _confirmPassword,
              hint: 're-enter new password',
              icon: Icons.lock_outline,
              obscure: true,
              validator: (v) {
                if (_newPassword.text.isEmpty) return null;
                if (v != _newPassword.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('SAVE CHANGES',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarPicker() {
    final p = SettingsService.profile.value;
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: _card,
            backgroundImage:
                p.avatarPath != null ? AssetImage(p.avatarPath!) : null,
            child: p.avatarPath == null
                ? const Icon(Icons.person, color: Colors.white70, size: 48)
                : null,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: GestureDetector(
              onTap: () {
                // TODO UC-20: integrasi image_picker + upload ke storage.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar upload coming soon')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _indigo,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 2),
                ),
                child: const Icon(Icons.camera_alt,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(color: _hint, fontSize: 12)),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _hint),
        prefixIcon: Icon(icon, color: _hint),
        filled: true,
        fillColor: _card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
