import 'package:flutter/material.dart';
import 'home_content.dart';
import 'tagihan_penghuni.dart';
import 'daftar_penghuni.dart';
import 'propil_penghuni.dart';
import 'dart:ui'; 
import 'chatbot.dart';
import '../widgets/transisi.dart';

class HomePenghuni extends StatefulWidget {
  @override
  _HomePenghuniState createState() => _HomePenghuniState();
}

class _HomePenghuniState extends State<HomePenghuni> {
  bool showChatbot = false;
  int currentIndex = 0;

  final List<Widget> pages = [
    HomeContent(),
    TagihanPenghuniPage(),
    DaftarPenghuniPage(),
    EditProfilPenghuniPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: pages,
          ),
          if (showChatbot)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          if (showChatbot)
            Positioned(
              left: 20,
              bottom: 80,
              top: 120,
              right: 20,
              child: GenieTransition(
                visible: showChatbot,
                origin: Alignment.bottomRight,
                child: ChatbotWidget(
                  onClose: () {
                    setState(() {
                      showChatbot = false;
                    });
                  },
                ),
              ),
            ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showChatbot = true;
          });
        },
        backgroundColor: Color(0xFF9E182B),
        child: Icon(Icons.chat,color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Color(0xFF9E182B),
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