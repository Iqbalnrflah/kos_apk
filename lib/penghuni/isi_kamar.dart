import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IsiKamar extends StatefulWidget {
  final String kosId;
  final String kamarId;

  const IsiKamar({super.key, required this.kosId, required this.kamarId});

  @override
  State<IsiKamar> createState() => _IsiKamarState();
}

class _IsiKamarState extends State<IsiKamar> {
  final nama = TextEditingController();
  final phone = TextEditingController();
  final kamar = TextEditingController();
  final tanggal = TextEditingController();

  Future<void> simpan() async {
  await FirebaseFirestore.instance
      .collection('kost')
      .doc(widget.kosId)
      .collection('kamar') // ✅ MASUK KE KAMAR
      .doc(widget.kamarId) // ✅ TARGET KAMAR
      .update({
    'penghuni_nama': nama.text,
    'penghuni_phone': phone.text,
    'tanggal_masuk': tanggal.text,
    'status': 'terisi', // 🔥 INI YANG BUAT WARNA BERUBAH
  });

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Berhasil mengisi kamar")),
  );

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Penghuni")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildInput("Nama Penghuni", nama),
            buildInput("Nomor WhatsApp", phone),
            buildInput("Nomor Kamar", kamar),
            buildInput("Tanggal Masuk", tanggal),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: simpan,
              child: const Text("Selesai"),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}