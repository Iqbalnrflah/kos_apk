import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'isi_kamar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/warning_dialog.dart';

class KamarPage extends StatelessWidget {
  final String kosId;

  const KamarPage({
    super.key,
    required this.kosId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kamar Kost"),
      ),

      body: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('kost')
                .doc(kosId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF9E182B),
                  child: const Text(
                    "Loading alamat...",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              }
              var data =
                  snapshot.data!.data()
                      as Map<String, dynamic>;
              String alamat =
                  data['alamat'] ??
                  "Alamat tidak tersedia";
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF9E182B),
                child: Text(
                  alamat,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kost')
                  .doc(kosId)
                  .collection('kamar')
                  .orderBy('nomor_kamar', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var kamarList = snapshot.data!.docs;
                kamarList.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                
                  return (da['nomor_kamar'] as int)
                      .compareTo(db['nomor_kamar'] as int);
                });

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: kamarList.length,
                  itemBuilder: (context, index) {
                    var kamar = kamarList[index];
                    var data =kamar.data()as Map<String, dynamic>;
                    bool isTerisi =data['status'] == 'terisi';
                    return GestureDetector(
                      onTap: isTerisi
                      ? null
                      : () async {
                          final user =
                              FirebaseAuth.instance.currentUser;
                          if (user == null) return;
                          final kamarCheck =
                              await FirebaseFirestore.instance
                                  .collectionGroup('kamar')
                                  .where('penghuniId', isEqualTo: user.uid)
                                  .where( 'status', isEqualTo: 'terisi')
                                  .get();
                          if (kamarCheck.docs.isNotEmpty) {
                            await showWarningDialog(
                              context,
                              "Kamu sudah menempati kamar lain. Hapus kamar lama untuk menempati kamar baru.",
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IsiKamar(
                                kosId: kosId,
                                kamarId: kamar.id,
                              ),
                            ),
                          );
                        },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isTerisi
                              ? Colors.grey[200]
                              : const Color(0xFF9E182B),
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF9E182B),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${data['nomor_kamar']}",
                            style: TextStyle(
                              color: isTerisi
                                  ? const Color(0xFF9E182B)
                                  : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}