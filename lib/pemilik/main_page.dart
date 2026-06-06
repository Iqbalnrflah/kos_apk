import 'package:flutter/material.dart';
import 'home_page.dart';
import 'pembayaran_page.dart';
import 'notifikasi_page.dart';
import 'riwayat_page.dart';
import 'tambah_kamar_page.dart';
class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  int index = 0;
  final pages = [
    HomePage(),
    PembayaranPage(),
    notifPage(),
    riwayatPage(),
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
    child: Container(
      width: 55,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color:
              active
                ? Colors.white
                : Colors.white70,
          ),
          SizedBox(height: 6),
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: active ? 22 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
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
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TambahKamarPage(),
          ),
        );
      },
      backgroundColor: Color(0xFF9E182B),
      elevation: 6,
      child: Icon(
        Icons.add,
        size: 30,
        color: Colors.white,
      ),
    ),

    floatingActionButtonLocation:FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: Container(
      height: 101,
      decoration: BoxDecoration(
        color: Color(0xFF9E182B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment:MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home, "Home", 0),
            navItem(Icons.receipt_long, "Tagihan", 1),
            SizedBox(width: 40),
            navItem(Icons.notifications, "Notif", 2),
            navItem(Icons.history, "Riwayat", 3),
          ],
        ),
      ),
    ),
  );
}
}