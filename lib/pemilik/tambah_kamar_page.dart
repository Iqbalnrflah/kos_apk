import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahKamarPage extends StatefulWidget {
  @override
  _TambahKamarPageState createState() => _TambahKamarPageState();
}

class _TambahKamarPageState extends State<TambahKamarPage> {
  final pemilik = TextEditingController();
  final namaKos = TextEditingController();
  final jumlahKamar = TextEditingController();
  final alamat = TextEditingController();
  final harga = TextEditingController();

  Future<void> tambahKamar() async {
  // 🔥 VALIDASI DULU
  if (pemilik.text.isEmpty ||
      namaKos.text.isEmpty ||
      jumlahKamar.text.isEmpty ||
      alamat.text.isEmpty ||
      harga.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Semua field wajib diisi")),
    );
    return;
  }

  int? totalKamar = int.tryParse(jumlahKamar.text);
  int? hargaKos = int.tryParse(harga.text);

  if (totalKamar == null || hargaKos == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Jumlah kamar & harga harus angka")),
    );
    return;
  }

  try {
    print("📤 Mulai kirim ke Firebase...");

    var kosRef = await FirebaseFirestore.instance.collection('kost').add({
      'pemilik': pemilik.text,
      'nama_kos': namaKos.text,
      'jumlah_kamar': totalKamar,
      'alamat': alamat.text,
      'harga': hargaKos,
      'created_at': Timestamp.now(), // 🔥 tambahan bagus
    });

    print("✅ Kos berhasil dibuat ID: ${kosRef.id}");

    // 🔥 AUTO BUAT KAMAR
    for (int i = 1; i <= totalKamar; i++) {
      await kosRef.collection('kamar').add({
        'No_Kamar': "Kamar $i",
        'status': "kosong",
      });
    }

    print("✅ Semua kamar berhasil dibuat");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kos & kamar berhasil dibuat")),
    );

    Navigator.pop(context);

  } catch (e) {
    print("❌ ERROR: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal tambah kos")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Kos"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: pemilik,
              decoration: InputDecoration(labelText: "Nama Pemilik"),
            ),
            TextField(
              controller: namaKos,
              decoration: InputDecoration(labelText: "Nama Kos"),
            ),
            TextField(
              controller: jumlahKamar,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Jumlah Kamar"),
            ),
            TextField(
              controller: alamat,
              decoration: InputDecoration(labelText: "Alamat Kos"),
            ),
            TextField(
              controller: harga,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Harga / Bulan"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: tambahKamar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Tambah Kos"),
            )
          ],
        ),
      ),
    );
  }
}