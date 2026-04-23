import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaftarPenghuniPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Pembayaran"),
        backgroundColor: Colors.red,
      ),

      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('pembayaran')
      .snapshots(),
  builder: (context, snapshot) {

    if (snapshot.hasError) {
      return Center(child: Text("Error: ${snapshot.error}"));
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    final docs = snapshot.data?.docs ?? [];

    if (docs.isEmpty) {
      return Center(child: Text("Belum ada pembayaran"));
    }

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {

        final item = docs[index].data() as Map<String, dynamic>;

        final nama = (item['penghuni_nama'] ?? "-").toString();
        final phone = (item['penghuni_phone'] ?? "-").toString();
        final status = (item['status'] ?? "belum lunas").toString();

        final raw = item['tanggal_bayar'];

        final tgl = raw is Timestamp
            ? raw.toDate()
            : DateTime.now();

        final waktu =
            "${tgl.day}/${tgl.month} ${tgl.hour.toString().padLeft(2, '0')}:${tgl.minute.toString().padLeft(2, '0')}";

        return ListTile(
          title: Text(nama),
          subtitle: Text(phone),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(waktu),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == "lunas"
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
    );
  },
),
    );
  }
}