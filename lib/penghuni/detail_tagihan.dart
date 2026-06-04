import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'midtrans_webview.dart';
import '../widgets/success_dialog.dart';

class DetailTagihanPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String kosId;
  final String kamarId;

  const DetailTagihanPage({
    super.key,
    required this.data,
    required this.kosId,
    required this.kamarId,
  });
  @override
  State<DetailTagihanPage> createState() => _DetailTagihanPageState();
}
class _DetailTagihanPageState extends State<DetailTagihanPage> {
  int totalTagihan = 0;
  String metode = "Transfer";
  @override
  void initState() {
    super.initState();
    totalTagihan = widget.data['harga'] ?? 0;
  }
  Future<void> bayarSekarang() async {
    if (totalTagihan <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tagihan tidak valid")),
      );
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("https://api.kospay.my.id/bayar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": widget.data['penghuni_nama'] ?? "User",
          "amount": totalTagihan,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception(response.body);
      }
      final data = jsonDecode(response.body);
      String url = data['url'];
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => MidtransWebView(url: url),
        ),
      );
        if (result == true) {
          var kostDoc = await FirebaseFirestore.instance
              .collection('kost')
              .doc(widget.kosId)
              .get();
          String ownerId = kostDoc['owner_id'];
          await FirebaseFirestore.instance
              .collection('pembayaran')
              .add({
            'penghuni_nama': widget.data['penghuni_nama'],
            'penghuni_phone': widget.data['penghuni_phone'],
            'kosId': widget.kosId,
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'ownerId': ownerId,
            'kamarId': widget.kamarId,
            'jumlah_bayar': totalTagihan,
            'total_tagihan': totalTagihan,
            'sisa_tagihan': 0,
            'status': 'Lunas',
            'metode': metode,
            'tanggal_bayar': FieldValue.serverTimestamp(),
          });

          await FirebaseFirestore.instance
              .collection('kost')
              .doc(widget.kosId)
              .collection('kamar')
              .doc(widget.kamarId)
              .update({
            'status_pembayaran': 'Lunas',
            'update_at': FieldValue.serverTimestamp(),
            'status_bayar': 'lunas',
          });
          await showSuccessDialog(context);
          Navigator.pop(context,true);
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pembayaran dibatalkan")),
        );
      }
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget boxItem(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    String nama = data['penghuni_nama'] ?? "-";
    String phone = data['penghuni_phone'] ?? "-";
    DateTime tgl = (data['tanggal_masuk'] is Timestamp)
      ? (data['tanggal_masuk'] as Timestamp).toDate()
      : DateTime.now();
    String jatuhTempo = "${tgl.day}/${tgl.month}/${tgl.year}";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Tagihan"),
        backgroundColor: Color(0xFF9E182B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                children: [
                  boxItem("Nama", nama),
                  boxItem("No WA", phone),
                  boxItem("Jatuh Tempo", jatuhTempo),
                  boxItem("Harga Sewa", "Rp $totalTagihan"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              enabled: false,
              controller: TextEditingController(
                text: totalTagihan.toString(),
              ),
              decoration: InputDecoration(
                labelText: "Jumlah Bayar",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  boxItem("Total Tagihan", "Rp $totalTagihan"),
                  boxItem("Status", "Belum Dibayar"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: bayarSekarang,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9E182B),
                padding: const EdgeInsets.all(16),
              ),
              child: const Text("Bayar Sekarang"),
            ),
          ],
        ),
      ),
    );
  }
}