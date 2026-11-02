import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  const CustomHeader({
    super.key,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 60,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          color: Colors.white,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
            
              // LOGO KOSTPAY
              Image.asset(
                "assets/img/LogoPay.png",
                height: 40,
              ),

              // Laporan Masalah
              Image.asset(
                "assets/img/LapMas.png",
                height: 40,
                color: Colors.black,
              ),
              // NOTIFIKASI
              IconButton(
                onPressed: () {
                  // buka halaman notifikasi
                },
                icon: const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}