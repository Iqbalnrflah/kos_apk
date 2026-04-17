import 'package:flutter/material.dart';

class NotifPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notif")),
      body: ListView(
        children: const [
          ListTile(title: Text("Tagihan belum dibayar")),
        ],
      ),
    );
  }
}