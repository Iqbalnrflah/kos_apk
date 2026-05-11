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
        size: 30,
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
        backgroundColor: Color(0xFF9E182B),
        elevation: 6,
        child: Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// 🔥 NAVBAR MINI TAPI ICON BESAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF9E182B),
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