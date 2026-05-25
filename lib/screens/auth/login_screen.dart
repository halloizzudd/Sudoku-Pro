import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Mock function untuk simulasi UC-01 Main Flow (Step 7-10) & Alternate Flow (A1)
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulasi network request
        await Future.delayed(const Duration(seconds: 2));

        // TODO: Implementasi autentikasi API sebenarnya di sini
        // bool isSuccess = await authService.login(...);

        // Simulasi sukses
        if (mounted) {
          // Navigasi ke Home (Step 10)
          // Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login berhasil!')),
          );
        }
      } catch (e) {
        // Simulasi A3 - Network Error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada koneksi internet / Error')),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna berdasarkan mockup
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                          // Validasi UC-01 (A2 - Format email invalid)
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            TextButton(
                              onPressed: () {
                                // Pindah ke UC-03
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(color: primaryColor, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
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
                                      Text('LOGIN TO PLAY',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // OR CONTINUE WITH
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

                        // SSO Buttons (UC-04)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.g_mobiledata, color: Colors.white), // Ganti dengan aset Google asli
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

                        // Create Account Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('New to the grid? ',
                                style: TextStyle(color: hintColor, fontSize: 12)),
                            GestureDetector(
                              onTap: () {
                                // Pindah ke UC-02
                              },
                              child: const Text(
                                'Create an Account',
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