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
      var kosRef = await FirebaseFirestore.instance.collection('kost').add({
        'pemilik': pemilik.text,
        'nama_kos': namaKos.text,
        'jumlah_kamar': totalKamar,
        'alamat': alamat.text,
        'harga': hargaKos,
        'created_at': Timestamp.now(),
      });

      for (int i = 1; i <= totalKamar; i++) {
        await kosRef.collection('kamar').add({
          'No_Kamar': "Kamar $i",
          'status': "kosong",
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kos & kamar berhasil dibuat")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal tambah kos")),
      );
    }
  }

  /// 🔥 INPUT SESUAI DESIGN
  Widget buildInput(TextEditingController controller, String hint,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 15, vertical: 12),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black54),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔥 BOX UTAMA
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black54),
                ),
                child: Column(
                  children: [
                    Text(
                      "Tambah Kost Baru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    buildInput(pemilik, "Nama Pemilik Kost"),
                    buildInput(namaKos, "Nama Kost"),
                    buildInput(jumlahKamar, "Jumlah Kamar",
                        keyboard: TextInputType.number),
                    buildInput(alamat, "Alamat Kost"),
                    buildInput(harga, "Harga Sewa Bulanan",
                        keyboard: TextInputType.number),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: tambahKamar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Selesai",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}