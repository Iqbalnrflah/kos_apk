import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiwayatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User belum login")),
      );
    }

    return Scaffold(
      body: Column(
        children: [ 
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15),
            color: Colors.red.shade800,
            child: Center(
              child: Text(
                "Daftar Tersimpan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// 🔥 LIST DATA DARI FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                /// 🔥 FILTER: DATA MILIK USER
                var data = snapshot.data!.docs.where((doc) {
                  var item = doc.data() as Map<String, dynamic>;
                  return item['penghuniId'] == user.uid;
                }).toList();

                if (data.isEmpty) {
                  return Center(child: Text("Belum ada riwayat"));
                }

                /// 🔥 SORT TERBARU DI ATAS
                data.sort((a, b) {
                  var aTime = (a['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now();
                  var bTime = (b['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: data.length,
                  itemBuilder: (context, index) {

                    var item = data[index].data() as Map<String, dynamic>;

                    String nama = item['penghuni_nama'] ?? "-";
                    String kos = item['nama_kos'] ?? "-";
                    String kamar = item['No_Kamar'] ?? "-";
                    String status = item['status_bayar'] ?? "belum";

                    /// 🔥 FORMAT TANGGAL
                    String tanggal = "-";
                    if (item['updated_at'] != null) {
                      DateTime t = (item['updated_at'] as Timestamp).toDate();
                      tanggal =
                          "${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year} . ${t.hour}:${t.minute.toString().padLeft(2, '0')}";
                    }

                    bool isLunas = status == "lunas";

                    return Column(
                      children: [

                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// LEFT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(kos, style: TextStyle(fontSize: 12)),
                                    Text(kamar, style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),

                              /// RIGHT
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    tanggal,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 6),

                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade800,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isLunas ? "Lunas" : "Belum Lunas",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        Divider(thickness: 1, color: Colors.black26),
                      ],
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