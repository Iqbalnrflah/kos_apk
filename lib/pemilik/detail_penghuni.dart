import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPenghuniPage extends StatelessWidget {
  final String kosId;
  final String kamarId;

  String formatTanggal(dynamic timestamp) {
  if (timestamp == null) return "-";

  try {
    DateTime date = (timestamp as Timestamp).toDate();

    return "${date.day}/${date.month}/${date.year}";
  } catch (e) {
    return "-";
  }
}

  DetailPenghuniPage({
    required this.kosId,
    required this.kamarId,
  });

  /// 🔥 FUNCTION KOSONGKAN KAMAR
  Future<void> kosongkanKamar(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('kost')
        .doc(kosId)
        .collection('kamar')
        .doc(kamarId)
        .update({
      'status': 'kosong',
      'penghuni_nama': null,
      'penghuni_phone': null,
      'tanggal_masuk': null,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kamar berhasil dikosongkan")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                color: Colors.red.shade800,
                child: Text(
                  alamat,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),

          /// 🔥 CONTENT
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 320,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('kost')
                        .doc(kosId)
                        .collection('kamar')
                        .doc(kamarId)
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return Column(
                        children: [

                          /// 🔥 BOX BESAR
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 400,
                              maxWidth: 350,
                            ),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black54),
                            ),
                            child: Column(
                              children: [

                                buildItem("No Kamar", data['No_Kamar']),
                                buildItem("Nama", data['penghuni_nama']),
                                buildItem("No HP", data['penghuni_phone']),
                                buildItem("Tanggal Masuk", formatTanggal(data['tanggal_masuk'])),

                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          /// 🔥 BUTTON KOSONGKAN
                          ElevatedButton(
                            onPressed: () => kosongkanKamar(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade800,
                              minimumSize: Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Kosongkan Kamar"),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 FIELD DI DALAM BOX (NESTED BOX)
  Widget buildItem(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // 🔥 radius dalam
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value?.toString() ?? "-",
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}