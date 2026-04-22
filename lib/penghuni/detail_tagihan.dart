import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailTagihanPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailTagihanPage({super.key, required this.data});

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
    if (jumlahBayar <= 0) return;

    await FirebaseFirestore.instance.collection('pembayaran').add({
      'penghuni_nama': widget.data['penghuni_nama'],
      'penghuni_phone': widget.data['penghuni_phone'],
      'jumlah_bayar': jumlahBayar,
      'total_tagihan': totalTagihan,
      'sisa_tagihan': sisa,
      'metode': metode,
      'tanggal_bayar': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pembayaran berhasil")),
    );

    Navigator.pop(context);
  }

  Widget boxItem(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12), // 🔥 SIKU LEMBUT
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

    DateTime tgl;
    var raw = data['tanggal_masuk'];

    if (raw is Timestamp) {
      tgl = raw.toDate();
    } else {
      tgl = DateTime.now();
    }

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

            /// 🔥 CARD UTAMA
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // 🔥 LEBIH HALUS
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

            /// 🔥 INPUT BAYAR
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

            /// 🔥 RINGKASAN
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

            /// 🔥 METODE
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

            /// 🔥 BUTTON
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