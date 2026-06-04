import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/header.dart';

class notifPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ownerId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(title: "Notifikasi"),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pembayaran')
                  .where('ownerId',isEqualTo: ownerId) 
                  .orderBy('tanggal_bayar', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error"));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var data = snapshot.data!.docs;
                if (data.isEmpty) {
                  return Center(child: Text("Belum ada notifikasi"));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var item =
                        data[index].data() as Map<String, dynamic>;
                    String title = 'Konfirmasi Pembayaran Berhasil';
                    String nama = item['penghuni_nama'] ?? "-";
                    String metode = item['metode'] ?? "-";
                    int nominal = item['jumlah_bayar'] ?? 0;
                    String tanggal = "-";
                    if (item['tanggal_bayar'] != null) {
                      DateTime t =
                          (item['tanggal_bayar'] as Timestamp).toDate();
                      tanggal =
                          "${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year} . ${t.hour}:${t.minute.toString().padLeft(2, '0')}";
                    }
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                      style: TextStyle(
                                        fontWeight:
                                          FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(nama,style:TextStyle(fontSize: 12)),
                                    Text(metode,style:TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:CrossAxisAlignment.end,
                                children: [
                                  Text(tanggal,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text("Rp.$nominal",
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.black26),
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