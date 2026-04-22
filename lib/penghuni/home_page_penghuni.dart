import 'package:flutter/material.dart';
import 'home_content.dart';
import 'tagihan_penghuni.dart';

class HomePenghuni extends StatefulWidget {
  @override
  _HomePenghuniState createState() => _HomePenghuniState();
}

class _HomePenghuniState extends State<HomePenghuni> {
  int currentIndex = 0;

  final List<Widget> pages = [
    HomeContent(),
    TagihanPenghuniPage(),
    Center(child: Text("Kamar")),
    Center(child: Text("Notif")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.red.shade800,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Tagihan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Daftar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notif",
          ),
        ],
      ),
    );
  }
}