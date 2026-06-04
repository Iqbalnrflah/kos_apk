import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/header.dart';

class riwayatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ownerId = FirebaseAuth.instance.currentUser!.uid;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User belum login")),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(title: "Riwayat Pembayaran"),
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var userData = userSnapshot.data!.data()as Map<String, dynamic>;
                String role =userData['role'] ?? "penghuni";
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                    .collectionGroup('pembayaran')
                    .where('ownerId', isEqualTo: ownerId)
                    .orderBy('tanggal_bayar', descending: true)
                    .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}",));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var data = snapshot.data!.docs;
                    if (data.isEmpty) {
                      return Center(child: Text("Belum ada riwayat"));
                    }

                    data.sort((a, b) {
                    var aData = a.data() as Map<String, dynamic>;
                    var bData = b.data() as Map<String, dynamic>;
                    DateTime aTime =
                      (aData['updated_at'] is Timestamp)
                        ? (aData['updated_at'] as Timestamp)
                          .toDate()
                        : DateTime.now();
                    DateTime bTime =
                      (bData['updated_at'] is Timestamp)
                        ? (bData['updated_at'] as Timestamp)
                          .toDate()
                        : DateTime.now();
                    return bTime.compareTo(aTime);
                  });
                    return ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        var item = data[index].data()as Map<String, dynamic>;
                        String nama =item['penghuni_nama'] ?? "-";
                        String metode =item['metode'] ?? "-";
                        String status =item['status'] ??"belum";
                        String tanggal;
                          if (item['tanggal_bayar'] is Timestamp) {
                            DateTime t = (item['tanggal_bayar'] as Timestamp)
                                    .toDate();
                            tanggal =
                                "${t.day.toString().padLeft(2, '0')}/"
                                "${t.month.toString().padLeft(2, '0')}/"
                                "${t.year} • "
                                "${t.hour.toString().padLeft(2, '0')}:"
                                "${t.minute.toString().padLeft(2, '0')}";
                          } else {
                            tanggal = "Menunggu Pembayaran";
                          }
                        bool isLunas = status == "Lunas";
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          padding: EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black26,),
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      isLunas
                                        ? "Konfirmasi Pembayaran Berhasil"
                                        : "Jatuh Tempo",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    tanggal,
                                    style: TextStyle(
                                      color: item['updated_at'] != null
                                        ? Colors.grey
                                        : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                nama,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    metode,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "Rp ${item['jumlah_bayar'] ?? 0}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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