import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'main_screen.dart';
import 'password_reset_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Giriş başarılı!')));
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-email':
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            errorMessage = 'E-posta veya şifre hatalı. Lütfen tekrar deneyin.';
            break;
          case 'too-many-requests':
            errorMessage =
                'Çok fazla deneme yapıldı. Bir süre sonra tekrar deneyin.';
            break;
          default:
            errorMessage = 'Bilinmeyen hata: ${e.code}';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _navigateToPasswordReset() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswordResetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Lottie.asset("assets/lottie/splash2.json", height: 160),
              const SizedBox(height: 10),
              const Text(
                "Hoş Geldiniz!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34495E),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Hesabınıza giriş yapın",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'E-posta girin'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Şifre girin'
                                  : null,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: const Color(0xFF34495E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: _navigateToPasswordReset,
                child: const Text(
                  "Şifremi Unuttum",
                  style: TextStyle(color: Color(0xFF34495E)),
                ),
              ),
              TextButton(
                onPressed: _navigateToRegister,
                child: const Text(
                  "Hesabınız yok mu? Kayıt olun",
                  style: TextStyle(color: Color(0xFF34495E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
