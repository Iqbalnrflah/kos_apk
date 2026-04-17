import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'isi_kamar.dart';

class KamarPage extends StatelessWidget {
  final String kosId;

  const KamarPage({super.key, required this.kosId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Kost")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kost')
            .doc(kosId)
            .collection('kamar')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var kamarList = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: kamarList.length,
            itemBuilder: (context, index) {
              var kamar = kamarList[index];
              var data = kamar.data() as Map<String, dynamic>;

              bool isTerisi = data['status'] == 'terisi';

              Color: isTerisi ? Colors.grey : Colors.red;
              return GestureDetector(
                onTap: isTerisi
    ? null // 🔒 tidak bisa diklik
    : () {
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
                    color: isTerisi ? Colors.grey : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      data['No_Kamar'] ?? kamar.id, // ✅ ANTI ERROR
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}