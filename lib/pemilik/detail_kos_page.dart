import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_penghuni.dart';

class DetailKosPage extends StatelessWidget {
  final String kosId;
  DetailKosPage({required this.kosId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kost')
                .doc(kosId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              var data = snapshot.data!.data() as Map<String, dynamic>;
              String alamat = data['alamat'] ?? "-";
              return Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF9E182B),
                ),
                child: Center(
                  child: Text(
                    alamat,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kost')
                  .doc(kosId)
                  .collection('kamar')
                  .orderBy('nomor_kamar', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var kamar = snapshot.data!.docs;
                kamar.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                  return (da['nomor_kamar'] as int)
                      .compareTo(db['nomor_kamar'] as int);
                });

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: kamar.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    var item = kamar[index].data() as Map<String, dynamic>;
                    String nama = item['No_Kamar']?.toString() ?? "-";
                    String status = item['status'] ?? "";
                    String huruf;
                    if (nama.contains("Kamar ")) {
                      huruf = nama.replaceAll("Kamar ", "");
                    } else {
                      huruf = nama;
                    }
                    bool isTerisi = status == "terisi";
                    return GestureDetector(
                      onTap: isTerisi
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPenghuniPage(
                                    kosId: kosId,
                                    kamarId: kamar[index].id,
                                  ),
                                ),
                              );
                            }
                          : null,

                      child: Container(
                        decoration: BoxDecoration(
                          color: isTerisi
                              ? Colors.white
                              : Color(0xFF9E182B),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Color(0xFF9E182B),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            huruf,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isTerisi
                                  ? Color(0xFF9E182B)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
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