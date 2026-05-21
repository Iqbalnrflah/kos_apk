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
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var kamarList = snapshot.data!.docs;
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
                    var data =kamar.data() as Map<String, dynamic>;
                    bool isTerisi =
                        data['status'] == 'terisi';
                    return GestureDetector(
                      onTap: isTerisi
                      ? null
                      : () async {
                      
                          final user =
                              FirebaseAuth.instance.currentUser;
                  
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Silakan login terlebih dahulu",
                                ),
                              ),
                            );
                            return;
                          }
                  
                          /// AMBIL SEMUA DATA KAMAR
                          final semuaKamar =
                              await FirebaseFirestore.instance
                                  .collectionGroup('kamar')
                                  .get();
                  
                          /// CEK APAKAH USER SUDAH PUNYA KAMAR
                          bool sudahIsi =
                              semuaKamar.docs.any((doc) {
                              
                            var kamarData =
                                doc.data() as Map<String, dynamic>;
                  
                            return kamarData['userId'] == user.uid &&
                                kamarData['status'] == 'terisi';
                          });
                  
                          /// JIKA SUDAH PUNYA KAMAR
                          if (sudahIsi) {
                          
                            await showWarningDialog(
                              context,
                              "Anda sudah mengisi kamar kos lain",
                            );
                  
                            return;
                          }
                  
                          /// JIKA BELUM
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