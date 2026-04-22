import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaftarPenghuniPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Penghuni"),
        backgroundColor: Colors.red,
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

          var data = snapshot.data!.docs;

          if (data.isEmpty) {
            return Center(child: Text("Belum ada penghuni"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {

              var item = data[index].data() as Map<String, dynamic>;

              String nama = item['penghuni_nama'] ?? "-";
              String kamar = item['No_Kamar'] ?? "-";
              String status = item['status_bayar'] ?? "belum";

              /// 🔥 HANDLE WAKTU
              DateTime waktu;
              var raw = item['tanggal_masuk'];

              if (raw is Timestamp) {
                waktu = raw.toDate();
              } else {
                waktu = DateTime.now();
              }

              String jam =
                  "${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}";

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black12,
                    )
                  ],
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// 🔹 KIRI (NAMA + KAMAR)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text("Kamar: $kamar"),
                      ],
                    ),

                    /// 🔹 KANAN (WAKTU + STATUS)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        /// ⏰ WAKTU
                        Text(
                          jam,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        SizedBox(height: 10),

                        /// 🔥 STATUS BADGE
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == "lunas"
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status == "lunas" ? "Lunas" : "Belum Lunas",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
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