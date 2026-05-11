import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotifPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15),
            color: Color(0xFF9E182B),
            child: Center(
              child: Text(
                "Notifikasi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifikasi')
                  .orderBy('created_at', descending: true)
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
                    String title = item['title'] ?? "-";
                    String nama = item['nama'] ?? "-";
                    String metode = item['metode'] ?? "-";
                    int nominal = item['nominal'] ?? 0;
                    String tanggal = "-";
                    if (item['created_at'] != null) {
                      DateTime t =
                          (item['created_at'] as Timestamp).toDate();
                      tanggal =
                          "${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year} . ${t.hour}:${t.minute.toString().padLeft(2, '0')}";
                    }
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(nama,
                                        style:
                                            TextStyle(fontSize: 12)),
                                    Text(metode,
                                        style:
                                            TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    tanggal,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Rp.$nominal",
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