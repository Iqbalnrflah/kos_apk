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

  void changeTab(int i) {
    setState(() {
      index = i;
    });
  }

  /// 🔥 ICON BESAR
  Widget navItem(IconData icon, int i) {
    bool active = index == i;

    return GestureDetector(
      onTap: () => changeTab(i),
      child: Icon(
        icon,
        size: 30, // 🔥 BESAR (ini yang kamu mau)
        color: active ? Colors.white : Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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

      /// 🔥 FAB NORMAL (jangan mini)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahKamarPage()),
          );
        },
        backgroundColor: Colors.red.shade900,
        elevation: 6,
        child: Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// 🔥 NAVBAR MINI TAPI ICON BESAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          shape: CircularNotchedRectangle(),
          notchMargin: 6,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                navItem(Icons.home, 0),
                navItem(Icons.receipt_long, 1),

                SizedBox(width: 10),

                navItem(Icons.notifications, 2),
                navItem(Icons.history, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}