import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'midtrans_webview.dart';

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
  final bayarController = TextEditingController();

  int totalTagihan = 0;
  int jumlahBayar = 0;
  int sisa = 0;

  String metode = "Transfer";

  @override
  void initState() {
    super.initState();

    totalTagihan = widget.data['harga'] ?? 0;
    sisa = totalTagihan;

    bayarController.addListener(() {
      setState(() {
        jumlahBayar = int.tryParse(bayarController.text) ?? 0;
        sisa = totalTagihan - jumlahBayar;
      });
    });
  }

  Future<void> bayarSekarang() async {
  if (jumlahBayar <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Masukkan jumlah bayar")),
    );
    return;
  }

  try {
    /// 🔥 REQUEST KE BACKEND NODE
    final response = await http.post(
      Uri.parse("http://10.0.2.2:3000/bayar"), // emulator
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nama": widget.data['penghuni_nama'] ?? "User",
        "amount": jumlahBayar,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal koneksi server");
    }

    final responsesData = jsonDecode(response.body);

    String url = responsesData['url'];

    /// 🔥 SIMPAN KE FIREBASE (PENDING)
    await FirebaseFirestore.instance.collection('pembayaran').add({
      'penghuni_nama': widget.data['penghuni_nama'],
      'penghuni_phone': widget.data['penghuni_phone'],
      'kosId': widget.kosId,
      'kamarId': widget.kamarId,
      'jumlah_bayar': jumlahBayar,
      'total_tagihan': totalTagihan,
      'sisa_tagihan': sisa,
      'status': 'pending', // 🔥 WAJIB pending dulu
      'metode': metode,
      'tanggal_bayar': FieldValue.serverTimestamp(),
    });

    /// 🔥 BUKA MIDTRANS
    final bool? result = await Navigator.push<bool>(
  context,
  MaterialPageRoute(
    builder: (_) => MidtransWebView(url: url),
  ),
);

if (result == true) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Pembayaran selesai")),
  );
}

  } catch (e) {
    print("ERROR: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal bayar, cek server")),
    );
  }
}

  Widget boxItem(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
        title: Text("Detail Tagihan"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
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

            SizedBox(height: 20),

            TextField(
              controller: bayarController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Jumlah Bayar",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  boxItem("Total Tagihan", "Rp $totalTagihan"),
                  boxItem("Jumlah Bayar", "Rp $jumlahBayar"),
                  boxItem("Sisa Tagihan", "Rp $sisa"),
                ],
              ),
            ),

            SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: metode,
              items: ["Transfer", "Cash", "E-Wallet"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  metode = val!;
                });
              },
              decoration: InputDecoration(
                labelText: "Metode Pembayaran",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: bayarSekarang,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Bayar Sekarang",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}