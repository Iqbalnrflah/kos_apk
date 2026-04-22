import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IsiKamar extends StatefulWidget {
  final String kosId;
  final String kamarId;

  const IsiKamar({
    super.key,
    required this.kosId,
    required this.kamarId,
  });

  @override
  State<IsiKamar> createState() => _IsiKamarState();
}

class _IsiKamarState extends State<IsiKamar> {
  final nama = TextEditingController();
  final phone = TextEditingController();

  int harga = 0;
  String noKamar = "-";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    ambilDataKamar();
  }

  Future<void> ambilDataKamar() async {
  /// 🔥 AMBIL DATA KAMAR
  var kamarDoc = await FirebaseFirestore.instance
      .collection('kost')
      .doc(widget.kosId)
      .collection('kamar')
      .doc(widget.kamarId)
      .get();

  var kamarData = kamarDoc.data() as Map<String, dynamic>?;

  /// 🔥 AMBIL DATA KOST (UNTUK BACKUP HARGA)
  var kostDoc = await FirebaseFirestore.instance
      .collection('kost')
      .doc(widget.kosId)
      .get();

  var kostData = kostDoc.data() as Map<String, dynamic>?;

  setState(() {
    noKamar = kamarData?['No_Kamar'] ?? "-";

    /// 🔥 PRIORITAS HARGA
    harga = kamarData?['harga'] ??
            kostData?['harga'] ?? 0;

    loading = false;
  });
}

  Future<void> simpan() async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('kost')
        .doc(widget.kosId)
        .collection('kamar')
        .doc(widget.kamarId)
        .set({
      'penghuni_nama': nama.text,
      'penghuni_phone': phone.text,

      /// 🔥 AUTO
      'penghuniId': user!.uid,
      'kosId': widget.kosId,
      'status': 'terisi',

      /// 🔥 AUTO DARI DATA KAMAR
      'No_Kamar': noKamar,
      'harga': harga,

      /// 🔥 AUTO TANGGAL
      'tanggal_masuk': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Berhasil menyimpan")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Isi Kamar")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔥 NO KAMAR
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "No Kamar: $noKamar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 10),

            /// 🔥 HARGA (READ ONLY)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Harga"),
                  Text(
                    "Rp $harga",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: nama,
              decoration: InputDecoration(labelText: "Nama"),
            ),

            TextField(
              controller: phone,
              decoration: InputDecoration(labelText: "No HP"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: simpan,
              child: Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}