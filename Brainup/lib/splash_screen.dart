import 'package:brainup/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart'; // LoginScreen'i import ediyoruz

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    await Future.delayed(Duration(seconds: 1)); // 4 saniye bekletme

    User? user =
        FirebaseAuth.instance.currentUser; // Kullanıcı oturumunu kontrol et

    if (user != null) {
      // Kullanıcı giriş yapmışsa HomeScreen'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      // Kullanıcı giriş yapmamışsa LoginScreen'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Image.asset(
          "assets/logo-removebg-preview.png",
          width: 128,
          height: 128,
        ),
      ),
    );
  }
}
