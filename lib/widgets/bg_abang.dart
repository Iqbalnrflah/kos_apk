import 'package:flutter/material.dart';

class BackgroundMerah extends StatelessWidget {
  final double height;
  final Widget? child;

  /// Radius sudut kiri-bawah dan kanan-bawah. Isi 0 kalau ingin lurus.
  final double radius;

  const BackgroundMerah({
    super.key,
    this.height = 190,
    this.child,
    this.radius = 20,
  });

  static const Color warnaMerah = Color(0xFF9E182B);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      decoration: BoxDecoration(
        color: warnaMerah,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(radius),
        ),
      ),
      child: child,
    );
  }
}