import 'package:brainup/custom_app_bar.dart';
import 'package:brainup/home_screen.dart';
import 'package:brainup/navigation_bar_widget.dart';
import 'package:brainup/old_test_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int activePage = 1;
  String? ngrokURL;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNgrokUrl();
    });
  }

  Future<void> _fetchNgrokUrl() async {
    _showLoadingDialog(); // yükleme başlamadan önce dialog göster

    try {
      final ref = FirebaseDatabase.instance.ref('ngrok_url');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          ngrokURL = "${snapshot.value}/predict";
        });
      } else {
        _showErrorDialog("Ngrok URL Firebase'de bulunamadı.");
      }
    } catch (e) {
      _showErrorDialog("URL çekilirken hata oluştu: $e");
    } finally {
      Navigator.of(context).pop(); // dialog kapat
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFF9F9F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF2C3E50),
                    strokeWidth: 5,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Sunucuya bağlanılıyor...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    Navigator.of(context).pop(); // önce yükleme dialogunu kapat
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Hata"),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("Tamam"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      OldTestScreen(),
      HomeScreen(
        onTabChange: (index) {
          setState(() {
            activePage = index;
          });
        },
        ngrokURL: ngrokURL ?? "",
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomAppBar(activePage: activePage),
      ),
      body: Stack(children: [pages[activePage]]),
      bottomNavigationBar: BottomNavigationBarWidget(
        onTabChange: (index) {
          setState(() {
            activePage = index;
          });
        },
        selectedIndex: activePage,
      ),
    );
  }
}
