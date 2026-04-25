import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PembayaranPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Data Pembayaran"),
        backgroundColor: Colors.red.shade800,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('kamar')
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          /// 🔥 FILTER: HANYA YANG BELUM BAYAR
          var data = snapshot.data!.docs.where((doc) {
            var item = doc.data() as Map<String, dynamic>;

            return item['status'] == "terisi" &&
                   item['status_bayar'] == "belum";
          }).toList();

          if (data.isEmpty) {
            return Center(child: Text("Semua penghuni sudah bayar"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {

              var doc = data[index];
              var item = doc.data() as Map<String, dynamic>;

              String nama = item['penghuni_nama'] ?? "-";
              String kamar = item['No_Kamar'] ?? "-";

              /// 🔥 AMBIL ID
              String kamarId = doc.id;
              String kosId = doc.reference.parent.parent?.id ?? "";

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          kamar,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Belum Bayar",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}