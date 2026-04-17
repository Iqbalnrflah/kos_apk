import 'package:flutter/material.dart';
import 'home_page_penghuni.dart';

class MainPagePenghuni extends StatefulWidget {
  @override
  _MainPagePenghuniState createState() => _MainPagePenghuniState();
}

class _MainPagePenghuniState extends State<MainPagePenghuni> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cari Kos")),

      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Cari nama kos...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          /// 📦 LIST
          Expanded(
            child: HomePenghuni(search: search),
          ),
        ],
      ),
    );
  }
}