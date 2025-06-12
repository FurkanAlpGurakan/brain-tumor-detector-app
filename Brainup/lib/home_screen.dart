import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;
  final String ngrokURL;
  const HomeScreen({
    super.key,
    required this.onTabChange,
    required this.ngrokURL,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Profil
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProfileExpanded = false;

  // Test
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        _nameController.text = userDoc['name'] ?? '';
        _emailController.text = userDoc['email'] ?? '';
      });
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
                'name': _nameController.text,
                'email': _emailController.text,
              });
          setState(() {});
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Bilgiler güncellendi')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isProfileExpanded = false;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isProfileExpanded = false;
      });
    }
  }

  Future<void> _testImage() async {
    if (_selectedImage == null) {
      _showError("Lütfen bir fotoğraf seçin.");
      return;
    }
    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final response = await http.post(
        Uri.parse(widget.ngrokURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String result = data['result'];
        double probability = data['probability'];
        await _saveResultToFirestore(result, probability);
        _showResult(result, probability);
      } else {
        _showError("API Hatası: ${response.body}");
      }
    } catch (e) {
      _showError("Bağlantı Hatası: $e");
    }
  }

  Future<void> _saveResultToFirestore(String result, double probability) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String downloadUrl = await _uploadImageToStorage(fileName);
      await FirebaseFirestore.instance.collection('test_results').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'image_url': downloadUrl,
        'result': result,
        'probability': probability,
        'date': DateTime.now(),
      });
    } catch (e) {
      _showError("Firestore kayıt hatası: $e");
    }
  }

  Future<String> _uploadImageToStorage(String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('test_images')
        .child(fileName);
    await ref.putFile(_selectedImage!);
    return await ref.getDownloadURL();
  }

  void _showResult(String result, double probability) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: const Color(0xFFF9F9F9),
            title: const Text(
              "Test Sonucu",
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        result.toLowerCase() == "normal"
                            ? Color(0xFF4CAF50).withOpacity(0.85)
                            : Color.fromARGB(255, 255, 0, 0).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        result.toLowerCase() == "normal"
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        result.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                LinearProgressIndicator(
                  value: probability,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    probability > 0.7
                        ? Color.fromARGB(255, 255, 0, 0)
                        : Color(0xFF4CAF50),
                  ),
                  minHeight: 16,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 15),
                Text(
                  "Olasılık: ${(probability * 100).toStringAsFixed(2)}%",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                // Ortalanmış buton
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Önce popup kapanır
                      setState(() {
                        _selectedImage = null; // Fotoğraf sıfırlanır
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text(
                      "Tamam",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Hata"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tamam"),
              ),
            ],
          ),
    );
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isProfileExpanded = !_isProfileExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  "assets/lottie/profil.json",
                                  height: 60,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Profilim",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  _isProfileExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 400),
                              crossFadeState:
                                  _isProfileExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                              firstChild: Container(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      _buildInput(
                                        "İsim Soyisim",
                                        _nameController,
                                        Icons.person,
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInput(
                                        "E-posta",
                                        _emailController,
                                        Icons.email,
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: _updateUserData,
                                        icon: const Icon(Icons.update),
                                        label: const Text("Bilgileri Güncelle"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white24,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: _buildTestArea(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            '"Erken teşhis, hayat kurtarır." - WHO',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFF34495E),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        // ✔ Yükleme alanı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (_selectedImage == null)
                const Text(
                  "Lütfen analiz için bir fotoğraf seçin ya da çekin.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    height: 280,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              const SizedBox(height: 40),
              if (_selectedImage == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _customButton(
                      "Kamera",
                      Icons.camera_alt,
                      _pickImageFromCamera,
                      const Color(0xFF34495E),
                    ),
                    const SizedBox(width: 20),
                    _customButton(
                      "Galeri",
                      Icons.photo_library,
                      _pickImageFromGallery,
                      const Color(0xFF34495E),
                    ),
                  ],
                ),
              if (_selectedImage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _customButton(
                      "Kaldır",
                      Icons.delete,
                      _removeSelectedImage,
                      const Color(0xFFE74C3C),
                    ),
                    const SizedBox(width: 20),
                    _customButton(
                      "Test Et",
                      Icons.science,
                      _testImage,
                      const Color(0xFF34495E),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // ✔ Son testler alanı
        _buildLastTests(),
      ],
    );
  }

  Widget _buildLastTests() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Başlık ve "Tümünü Gör" butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Son Testler",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onTabChange(0); // activePage = 0 olacak
                },
                child: const Text(
                  "Tümünü Gör",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('test_results')
                  .where('userId', isEqualTo: userId)
                  .orderBy('date', descending: true)
                  .limit(4) // Artık 5 test gösteriyoruz
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Son test bulunamadı."));
            }

            final docs = snapshot.data!.docs;
            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final imageUrl = doc['image_url'];
                  final result = doc['result'];
                  final probability = doc['probability'];
                  final timestamp = doc['date'] as Timestamp;
                  final formattedDate = DateFormat(
                    'yyyy-MM-dd HH:mm',
                  ).format(timestamp.toDate());

                  return Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (result.toLowerCase() == "anormal")
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFE74C3C),
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sonuç: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    result.toLowerCase() == "normal"
                                        ? Colors.green
                                        : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                result.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: LinearProgressIndicator(
                            value: probability,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              probability > 0.6 ? Colors.red : Colors.green,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Olasılık: ${(probability * 100).toStringAsFixed(2)}% | Tarih: $formattedDate',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _customButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color bgColor,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20), // ikon büyüdü
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20, // font büyüdü
          fontWeight: FontWeight.bold, // biraz kalın
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ), // padding büyüdü
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // köşeler yumuşadı
        ),
        elevation: 6, // hafif gölge verdik
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator:
          (value) => value == null || value.isEmpty ? '$label giriniz' : null,
    );
  }
}
