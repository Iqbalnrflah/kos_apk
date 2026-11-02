import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kospay_dart/pemilik/main_page.dart';
import 'package:kospay_dart/penghuni/home_page_penghuni.dart';
import '../pemilik/register_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Color warnaMerah = Color(0xFF9E182B);

  @override
  void initState() {
    super.initState();
    _cekSesi();
  }

  // Pindah halaman dengan efek fade.
  void _pindah(Widget halaman) {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => halaman,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  Future<void> _cekSesi() async {
    // Jeda minimal agar animasi splash sempat terlihat.
    final jeda = Future.delayed(const Duration(milliseconds: 1800));

    final currentUser = FirebaseAuth.instance.currentUser;

    // Belum login: ke halaman login.
    if (currentUser == null) {
      await jeda;
      _pindah(AuthPage());
      return;
    }

    try {
      final data = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Akun ada di Auth tapi datanya tidak ada di Firestore.
      if (!data.exists) {
        await FirebaseAuth.instance.signOut();
        await jeda;
        _pindah(AuthPage());
        return;
      }

      final userData = data.data() as Map<String, dynamic>;
      final String role = userData['role'] ?? 'penghuni';

      await jeda;
      _pindah(role == 'pemilik' ? MainPage() : HomePenghuni());
    } catch (e) {
      // Misalnya tidak ada internet: tampilkan halaman login.
      await jeda;
      _pindah(AuthPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.7 + (0.3 * value),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/img/LogoPay.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'KosPay',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: warnaMerah,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: warnaMerah,
                      strokeWidth: 2.5,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Memuat...',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}