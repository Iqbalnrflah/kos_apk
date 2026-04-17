import 'package:flutter/material.dart';

class PembayaranPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pembayaran")),
      body: Center(child: Text("Tagihan: Rp 500.000")),
    );
  }
}