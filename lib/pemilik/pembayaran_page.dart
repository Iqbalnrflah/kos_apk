import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/header.dart';

class PembayaranPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomHeader(
          title: "Daftar Pembayaran",
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('kamar')
                .snapshots(),

            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                  ),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              var data =
                  snapshot.data!.docs.where((doc) {

                var item =
                    doc.data()
                        as Map<String, dynamic>;

                return item['status'] == "terisi" &&
                    item['status_bayar'] == "belum";

              }).toList();

              if (data.isEmpty) {
                return Center(
                  child: Text(
                    "Semua penghuni sudah bayar",
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 120,
                ),

                itemCount: data.length,

                itemBuilder: (context, index) {

                  var doc = data[index];

                  var item =
                      doc.data()
                          as Map<String, dynamic>;

                  String nama =
                      item['penghuni_nama'] ?? "-";

                  String kamar =
                      item['No_Kamar'] ?? "-";

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
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              nama,

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            SizedBox(height: 6),

                            Text(
                              "Kamar $kamar",

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
                                BorderRadius.circular(
                              20,
                            ),
                          ),

                          child: Text(
                            "Belum Bayar",

                            style: TextStyle(
                              color: Color(0xFF9E182B),
                              fontWeight:
                                  FontWeight.bold,
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