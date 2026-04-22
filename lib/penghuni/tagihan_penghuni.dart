import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TagihanPenghuniPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User belum login")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Tagihan Saya"),
        backgroundColor: Colors.red,
      ),

      body: StreamBuilder<QuerySnapshot>(
        /// 🔥 AMBIL SEMUA KAMAR (AMAN)
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

          /// 🔥 FILTER USER (ANTI HILANG)
          var data = snapshot.data!.docs.where((doc) {
            var item = doc.data() as Map<String, dynamic>;
            return item['penghuniId'] == uid;
          }).toList();

          if (data.isEmpty) {
            return Center(child: Text("Belum ada tagihan"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {

              var item = data[index].data() as Map<String, dynamic>;

              String nama = item['penghuni_nama'] ?? "-";

              /// 🔥 HANDLE TANGGAL (SUPER AMAN)
              DateTime tglMasuk;
              final raw = item['tanggal_masuk'];

              if (raw is Timestamp) {
                tglMasuk = raw.toDate();
              } else {
                tglMasuk = DateTime.now();
              }

              /// 🔥 STATUS
              bool jatuhTempo = DateTime.now().day >= tglMasuk.day;
              String status = jatuhTempo ? "Jatuh Tempo" : "Mendatang";

              /// 🔥 BULAN
              int nextMonth = tglMasuk.month == 12 ? 1 : tglMasuk.month + 1;
              int year = tglMasuk.month == 12 ? tglMasuk.year + 1 : tglMasuk.year;

              String bulan = "$nextMonth/$year";

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
                          status,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bulan,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
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