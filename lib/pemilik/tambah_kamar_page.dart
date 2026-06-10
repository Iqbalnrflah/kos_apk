  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';

  class TambahKamarPage extends StatefulWidget {
    @override
    _TambahKamarPageState createState() => _TambahKamarPageState();
  }
  class _TambahKamarPageState extends State<TambahKamarPage> {
    bool isLoading = false;
    final pemilik = TextEditingController();
    final namaKos = TextEditingController();
    final jumlahKamar = TextEditingController();
    final alamat = TextEditingController();
    final harga = TextEditingController();
    Future<void> tambahKamar() async {
      if (isLoading) return;
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
      setState(() {isLoading = true;});
      try {
        var kosRef = await FirebaseFirestore.instance.collection('kost').add({
          'pemilik': pemilik.text,
          'nama_kos': namaKos.text,
          'owner_id': FirebaseAuth.instance.currentUser!.uid,
          'jumlah_kamar': totalKamar,
          'alamat': alamat.text,
          'harga': hargaKos,
          'created_at': Timestamp.now(),
        });

        for (int i = 1; i <= totalKamar; i++) {
          await kosRef.collection('kamar').add({
            'No_Kamar': "Kamar $i",
            'nomor_kamar': i,
            'status': "kosong",
          });
        }
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              content: const Text(
                "Kos & kamar berhasil dibuat",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E182B),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal tambah kos"),
          ),
        );
      }
    }
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
            contentPadding:EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
              borderSide: BorderSide(color: Color(0xFF9E182B)),
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
                    onPressed: isLoading ? null : tambahKamar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9E182B),
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),  
                    child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          "Selesai",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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