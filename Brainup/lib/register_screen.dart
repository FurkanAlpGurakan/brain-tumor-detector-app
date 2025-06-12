import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': Timestamp.now(),
            });

        FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
          ),
        );

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Bu e-posta ile zaten bir hesap mevcut.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Geçerli bir e-posta adresi giriniz.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Şifreniz en az 6 karakter olmalıdır.';
        } else {
          errorMessage = 'Bir hata oluştu: ${e.code}';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
      }
    }
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
                "Kayıt Ol",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34495E),
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'İsim Soyisim',
                      icon: Icons.person,
                      validatorMsg: 'İsim giriniz',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'E-posta',
                      icon: Icons.email_outlined,
                      validatorMsg: 'E-posta giriniz',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      labelText: 'Şifre',
                      icon: Icons.lock_outline,
                      validatorMsg: 'Şifre giriniz',
                      obscure: true,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: const Color(0xFF34495E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Zaten hesabınız var mı? Giriş yapın',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF34495E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String validatorMsg,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        return null;
      },
    );
  }
}
