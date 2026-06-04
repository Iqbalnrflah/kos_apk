import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/header.dart';

class PembayaranPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomHeader(title: "Daftar Pembayaran"),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
            .collectionGroup('kamar')
            .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              }
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final ownerId = FirebaseAuth.instance.currentUser!.uid;
              List<QueryDocumentSnapshot> data = 
              snapshot.data!.docs.where((doc) {
                var item = doc.data() as Map<String, dynamic>;
                String statusBayar = item['status_bayar'] ?? "belum";
                return item['ownerId'] == ownerId && item['status'] == 'terisi';
              }).toList();
              if (data.isEmpty) {
                return const Center(
                  child: Text("Belum ada pembayaran"),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.only(top: 10,bottom: 120,),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var doc = data[index];
                  var item = doc.data() as Map<String, dynamic>;
                  String nama = item['penghuni_nama'] ?? "-";
                  String kamar = item['No_Kamar'] ?? "-";
                  String statusBayar = item['status_bayar'] ?? "belum";
                  return Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF9E182B),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: [
                            Text(nama,
                              style: TextStyle(
                                color: statusBayar == "lunas"
                                  ? Colors.green.shade100
                                  : Colors.white,
                                fontWeight:
                                  FontWeight.bold,
                                  fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text("$kamar",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding:
                            EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                              BorderRadius.circular(20,),
                          ),
                          child: Text(
                            statusBayar == "lunas"
                              ? "Lunas"
                              : "Belum Lunas",
                            style: TextStyle(
                              color: statusBayar == "lunas"
                                ? Colors.green
                                  : const Color(0xFF9E182B),
                              fontWeight:FontWeight.bold,
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
        ),
      ],
    );
  }
}