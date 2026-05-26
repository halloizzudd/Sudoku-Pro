import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../root_shell.dart';
import 'linking_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Fungsi simulasi untuk UC-02 Main Flow (Step 6-8)
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulasi network request ke backend
        await Future.delayed(const Duration(seconds: 2));

        // TODO: Implementasi register API sebenarnya di sini
        // bool isSuccess = await authService.register(...);

        // Step 7 & 8: auto-login & redirect Home.
        await _completeAuth(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
        );
      } catch (e) {
        // Simulasi A1 - Email sudah terdaftar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email sudah digunakan')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // UC-04: SSO dummy — "Linking account..." lalu register/login lokal.
  Future<void> _handleSso(String provider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LinkingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.of(context).pop();
    await _completeAuth(
      username: '$provider Player',
      email: '${provider.toLowerCase()}@sudokupro.app',
    );
  }

  // Simpan token mock + profil lalu masuk Home (dipakai register & SSO).
  Future<void> _completeAuth({
    required String username,
    required String email,
  }) async {
    await LocalStorageService.saveAuthToken(
        'mock-${DateTime.now().millisecondsSinceEpoch}');
    final current = SettingsService.profile.value;
    await SettingsService.updateProfile(
        current.copyWith(username: username, email: email));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna mengikuti tema aktif (Light/Dark) lewat AppColors.
    final c = context.colors;
    final Color bgColor = c.background;
    final Color cardColor = c.surface;
    final Color primaryColor = c.primary;
    final Color textColor = c.textPrimary;
    final Color hintColor = c.textSecondary;
    final Color fieldFill = c.inputFill;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo & Header ---
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.grid_on, color: textColor, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'SUDOKU PRO',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sharpen Your Mind',
                  style: TextStyle(color: hintColor, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // --- Form Container ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username Field (UC-02: wajib)
                        Text('USERNAME',
                            style: TextStyle(color: hintColor, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'choose a username',
                            hintStyle: TextStyle(color: hintColor),
                            prefixIcon: Icon(Icons.person_outline,
                                color: hintColor),
                            filled: true,
                            fillColor: fieldFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          // Aturan UC-02: 3–20 karakter, alfanumerik + underscore
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            final re = RegExp(r'^[A-Za-z0-9_]{3,20}$');
                            if (!re.hasMatch(value)) {
                              return '3-20 karakter, alfanumerik / underscore';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        Text('EMAIL ADDRESS',
                            style: TextStyle(color: hintColor, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'enter your email',
                            hintStyle: TextStyle(color: hintColor),
                            prefixIcon: Icon(Icons.email_outlined, color: hintColor),
                            filled: true,
                            fillColor: fieldFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Text('PASSWORD',
                            style: TextStyle(color: hintColor, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'enter your password',
                            hintStyle: TextStyle(color: hintColor),
                            prefixIcon: Icon(Icons.lock_outline, color: hintColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: hintColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: fieldFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          // Validasi UC-02 (A4 - Password Lemah)
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            // Aturan: min 8 karakter, ada huruf & angka
                            final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
                            if (!passwordRegex.hasMatch(value)) {
                              return 'Min 8 karakter, harus mengandung huruf & angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Confirmation Field
                        Text('PASSWORD CONFIRMATION',
                            style: TextStyle(color: hintColor, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'enter your password',
                            hintStyle: TextStyle(color: hintColor),
                            prefixIcon: Icon(Icons.lock_outline, color: hintColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: hintColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: fieldFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          // Validasi UC-02 (A3 - Password & confirm tidak match)
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                            if (value != _passwordController.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Remember Me
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                fillColor: MaterialStateProperty.resolveWith(
                                    (states) => fieldFill),
                                checkColor: primaryColor,
                                side: BorderSide(color: hintColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Remember me',
                                style: TextStyle(color: hintColor, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // OR CONTINUE WITH Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: hintColor, thickness: 0.5)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('OR CONTINUE WITH',
                                  style: TextStyle(color: hintColor, fontSize: 10)),
                            ),
                            Expanded(child: Divider(color: hintColor, thickness: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('CREATE ACCOUNT',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // SSO Buttons (Google / Apple)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _handleSso('Google'),
                                icon: Icon(Icons.g_mobiledata, color: textColor),
                                label: Text('Google', style: TextStyle(color: textColor)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: hintColor, width: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _handleSso('Apple'),
                                icon: Icon(Icons.apple, color: textColor),
                                label: Text('Apple', style: TextStyle(color: textColor)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: hintColor, width: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already Have Account? ',
                                style: TextStyle(color: hintColor, fontSize: 12)),
                            GestureDetector(
                              onTap: () {
                                // Kembali ke screen Login (UC-01)
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(color: primaryColor, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Footer ---
                Text(
                  'BY LOGGING IN YOU AGREE TO OUR\nTERMS OF SERVICE & PRIVACY POLICY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hintColor,
                    fontSize: 10,
                    letterSpacing: 1.0,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}