import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat")),
      body: ListView(
        children: const [
          ListTile(title: Text("Januari - Lunas")),
        ],
      ),
    );
  }
}