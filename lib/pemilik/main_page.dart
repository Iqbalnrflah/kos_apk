import 'package:flutter/material.dart';
import 'home_page.dart';
import 'pembayaran_page.dart';
import 'notif_page.dart';
import 'riwayat_page.dart';
import 'tambah_kamar_page.dart';
import 'profil_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  final pages = [
    HomePage(),
    PembayaranPage(),
    NotifPage(),
    RiwayatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilPage()),
              );
            },
          )
        ],
      ),

      body: pages[index],

      // 🔥 TOMBOL TENGAH
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahKamarPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 253, 66, 52),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🔻 NAVBAR BAWAH
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.red, width: 3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () => setState(() => index = 0),
              ),

              IconButton(
                icon: Icon(Icons.payment),
                onPressed: () => setState(() => index = 1),
              ),

              SizedBox(width: 40), // ruang FAB

              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () => setState(() => index = 2),
              ),

              IconButton(
                icon: Icon(Icons.history),
                onPressed: () => setState(() => index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}