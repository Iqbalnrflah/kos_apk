import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailKosPage extends StatelessWidget {
  final String kosId;

  DetailKosPage({required this.kosId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Kamar")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kost')
            .doc(kosId)
            .collection('kamar')
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var kamar = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(16),
            itemCount: kamar.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 🔥 3 kolom
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              var item = kamar[index];

              String nama = item['nama_kamar']; // ✅ fix
              String status = item['status'];

              // 🔥 ambil angka dari "Kamar 1"
              String nomor = nama.replaceAll("Kamar ", "");

              bool isTerisi = status == "terisi";

              return Container(
                decoration: BoxDecoration(
                  color: isTerisi ? Colors.white : Colors.red,
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    nomor,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isTerisi ? Colors.red : Colors.white,
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