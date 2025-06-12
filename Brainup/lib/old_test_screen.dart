import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OldTestScreen extends StatefulWidget {
  const OldTestScreen({super.key});

  @override
  State<OldTestScreen> createState() => _OldTestScreenState();
}

class _OldTestScreenState extends State<OldTestScreen> {
  String selectedFilter = "Hepsi";

  // Ortak renk fonksiyonumuz:
  Color getColorForProbability(double probability) {
    return probability > 0.7 ? Colors.red : Colors.green;
  }

  Stream<QuerySnapshot> getUserTestResults() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('test_results')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  void deleteTest(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('test_results')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Test silindi.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Silme işlemi başarısız: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFilterButtons(),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getUserTestResults(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Bir hata oluştu: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Henüz kayıtlı testiniz bulunmuyor.'),
                      );
                    }

                    final filteredDocs =
                        snapshot.data!.docs.where((doc) {
                          final result = doc['result'].toString().toLowerCase();
                          if (selectedFilter == "Hepsi") return true;
                          if (selectedFilter == "Normal")
                            return result == "normal";
                          if (selectedFilter == "Anormal")
                            return result == "anormal";
                          return true;
                        }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Seçtiğiniz filtreye ait sonuç bulunamadı.',
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final date = (doc['date'] as Timestamp).toDate();
                        final formattedDate = DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(date);
                        final probability = doc['probability'] as double;
                        final result = doc['result'];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    doc['image_url'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (result.toLowerCase() == "anormal")
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      color: const Color(0xFFE74C3C),
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                            title: Row(
                              children: [
                                const Text(
                                  "Sonuç: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: probability,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    getColorForProbability(probability),
                                  ),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Olasılık: ${(probability * 100).toStringAsFixed(2)}% | Tarih: $formattedDate',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFFE74C3C),
                              ),
                              onPressed: () => _confirmDelete(context, doc.id),
                            ),
                            onTap: () => _showTestDetails(context, doc),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ["Hepsi", "Normal", "Anormal"];
    return Wrap(
      spacing: 10,
      children:
          filters.map((label) {
            bool isSelected = selectedFilter == label;
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedFilter = label;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? const Color(0xFF2C3E50) : Colors.white,
                foregroundColor:
                    isSelected ? Colors.white : const Color(0xFF2C3E50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: const Color(0xFF2C3E50), width: 1.5),
                ),
                elevation: isSelected ? 6 : 2,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: const Color(0xFFF9F9F9),
            title: const Text(
              'Test Sil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF2C3E50),
              ),
            ),
            content: const Text(
              'Bu testi silmek istediğinize emin misiniz?',
              style: TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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
                  "İptal",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  deleteTest(context, docId);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Sil",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showTestDetails(BuildContext context, QueryDocumentSnapshot doc) {
    final date = (doc['date'] as Timestamp).toDate();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    final result = doc['result'].toString();
    final probability = doc['probability'] as double;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            color: const Color(0xFFF9F9F9),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(1),
                    ),
                    child: Image.network(
                      doc['image_url'],
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sonuç: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              result.toLowerCase() == "normal"
                                  ? const Color(0xFF4CAF50)
                                  : const Color.fromARGB(255, 255, 0, 0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          result.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      value: probability,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        getColorForProbability(probability),
                      ),
                      minHeight: 14,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Olasılık: ${(probability * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tarih: $formattedDate',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text("Kapat", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
