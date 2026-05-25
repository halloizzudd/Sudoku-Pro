import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
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

        // Simulasi sukses (Step 7 & 8: Auto-login & redirect Home)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi berhasil! Mengalihkan...')),
          );
          // Navigator.pushReplacementNamed(context, '/home');
        }
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna yang sama dengan Login Screen
    const Color bgColor = Color(0xFF0F0F1A);
    const Color cardColor = Color(0xFF1E1E2E);
    const Color primaryColor = Color(0xFF5C4EE5);
    const Color textColor = Colors.white;
    const Color hintColor = Colors.grey;

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
                  child: const Icon(Icons.grid_on, color: textColor, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SUDOKU PRO',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
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
                        // Email Field
                        const Text('EMAIL ADDRESS',
                            style: TextStyle(color: hintColor, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'enter your email',
                            hintStyle: const TextStyle(color: hintColor),
                            prefixIcon: const Icon(Icons.email_outlined, color: hintColor),
                            filled: true,
                            fillColor: bgColor,
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
                        const Text('PASSWORD',
                            style: TextStyle(color: hintColor, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'enter your password',
                            hintStyle: const TextStyle(color: hintColor),
                            prefixIcon: const Icon(Icons.lock_outline, color: hintColor),
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
                            fillColor: bgColor,
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
                        const Text('PASSWORD CONFIRMATION',
                            style: TextStyle(color: hintColor, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: const TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'enter your password',
                            hintStyle: const TextStyle(color: hintColor),
                            prefixIcon: const Icon(Icons.lock_outline, color: hintColor),
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
                            fillColor: bgColor,
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
                                    (states) => bgColor),
                                checkColor: primaryColor,
                                side: const BorderSide(color: hintColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Remember me',
                                style: TextStyle(color: hintColor, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // OR CONTINUE WITH Divider
                        const Row(
                          children: [
                            Expanded(child: Divider(color: hintColor, thickness: 0.5)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
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
                                onPressed: () {},
                                icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                                label: const Text('Google', style: TextStyle(color: textColor)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: hintColor, width: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.apple, color: Colors.white),
                                label: const Text('Apple', style: TextStyle(color: textColor)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: hintColor, width: 0.5),
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
                            const Text('Already Have Account? ',
                                style: TextStyle(color: hintColor, fontSize: 12)),
                            GestureDetector(
                              onTap: () {
                                // Kembali ke screen Login (UC-01)
                                Navigator.pop(context);
                              },
                              child: const Text(
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
                const Text(
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