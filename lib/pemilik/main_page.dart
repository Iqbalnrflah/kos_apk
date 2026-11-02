import 'package:flutter/material.dart';
import 'home_page.dart';
import 'tagihan_pemilik.dart';
import 'riwayat_page.dart';
import 'profil_page.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  final pages = [
    HomePage(),
    TagihanPemilikPage(),
    RiwayatPage(),
    ProfilPage(),
  ];

  void changeTab(int i) {
    setState(() {
      index = i;
    });
  }

  Widget navItem(
    IconData icon,
    String label,
    int i,
  ) {
    bool active = index == i;

    return GestureDetector(
      onTap: () => changeTab(i),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          // Pill pink lembut untuk tab aktif
          color: active ? Color(0x40FFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? Colors.white : Colors.white70,
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF9E182B),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          height: 62,
          padding: EdgeInsets.zero,
          shape: CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(Icons.home_outlined, "Beranda", 0),
              navItem(Icons.receipt_long_outlined, "Tagihan", 1),
              navItem(Icons.history, "Riwayat", 2),
              navItem(Icons.person_outline, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }
}