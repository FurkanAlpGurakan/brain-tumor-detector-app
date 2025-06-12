import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'login_screen.dart';

class CustomAppBar extends StatelessWidget {
  final int activePage;

  const CustomAppBar({super.key, required this.activePage});

  Future<void> _signOut(BuildContext context) async {
    bool? confirmSignOut = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: const Color(0xFFF9F9F9),
            title: const Text(
              "Çıkış Yap",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF2C3E50),
              ),
            ),
            content: const Text(
              "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
              style: TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Hayır",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Evet",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmSignOut == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF2C3E50), // Antrasit renk
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sol köşe splash animasyon
            Lottie.asset('assets/lottie/splash2.json', width: 50, height: 50),

            // Uygulama başlığı
            const Text(
              'BrainUp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            // Sağ üstte çıkış butonu yalnızca profil sayfasında
            if (activePage == 1)
              GestureDetector(
                onTap: () => _signOut(context),
                child: Lottie.asset(
                  'assets/lottie/exit.json',
                  width: 45,
                  height: 45,
                ),
              )
            else
              const SizedBox(width: 50), // Boşluk koruyucu
          ],
        ),
      ),
    );
  }
}
