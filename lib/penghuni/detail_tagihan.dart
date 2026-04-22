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
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [

            Text("Nama: $nama"),
            Text("No WA: $phone"),
            Text("Jatuh Tempo: $jatuhTempo"),
            Text("Harga Sewa: Rp $totalTagihan"),

            SizedBox(height: 20),

            TextField(
              controller: bayarController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Jumlah Bayar",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            Text("Total Tagihan: Rp $totalTagihan"),
            Text("Jumlah Bayar: Rp $jumlahBayar"),
            Text("Sisa Tagihan: Rp $sisa"),

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
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: bayarSekarang,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.all(15),
              ),
              child: Text("Bayar Sekarang"),
            )
          ],
        ),
      ),
    );
  }
}