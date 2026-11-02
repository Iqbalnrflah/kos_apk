import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/bg_abang.dart';
import 'tambah_kamar_page.dart';

class DaftarKostPage extends StatelessWidget {
  const DaftarKostPage({super.key});

  static const Color warnaMerah = Color(0xFF9E182B);

  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    final double bawah = MediaQuery.of(context).padding.bottom;

    // Posisi daftar kost dan panjang merah (merah turun ke belakang daftar).
    final double topForm = statusBar + 135;
    final double tinggiHeader = topForm + 75;

    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // HEADER MERAH
            BackgroundMerah(
              height: tinggiHeader,
              child: Padding(
                padding: EdgeInsets.only(top: statusBar),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(-12, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Kost',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Daftar Kost\nAnda Di Sini !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // DAFTAR KOST + TOMBOL
            Positioned(
              top: topForm,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Expanded(
                    child: uid == null
                        ? const Center(
                            child: Text('Silakan login terlebih dahulu'),
                          )
                        : StreamBuilder<QuerySnapshot>(
                            // Hanya kost milik akun yang sedang login.
                            stream: FirebaseFirestore.instance
                                .collection('kost')
                                .where('owner_id', isEqualTo: uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: warnaMerah,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }

                              final docs = [...(snapshot.data?.docs ?? [])];

                              // Terbaru di atas
                              docs.sort((a, b) {
                                final da = a.data() as Map<String, dynamic>;
                                final db = b.data() as Map<String, dynamic>;
                                final ta = da['created_at'];
                                final tb = db['created_at'];
                                if (ta is Timestamp && tb is Timestamp) {
                                  return tb.compareTo(ta);
                                }
                                return 0;
                              });

                              if (docs.isEmpty) {
                                return ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    12,
                                  ),
                                  children: [_buildKosong()],
                                );
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                itemCount: docs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final data = docs[index].data()
                                      as Map<String, dynamic>;
                                  return _buildKartuKost(context, data);
                                },
                              );
                            },
                          ),
                  ),

                  // TOMBOL TAMBAH KOST
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bawah),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TambahKamarPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Tambah Kost',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: warnaMerah,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TAMPILAN KOSONG (kartu putih)
  // ==========================================================
  Widget _buildKosong() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada kost',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ketuk tombol di bawah untuk menambahkan kost',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // KARTU KOST
  // ==========================================================
  Widget _buildKartuKost(BuildContext context, Map<String, dynamic> data) {
    final String namaKos = data['nama_kos']?.toString() ?? '-';
    final String tipe = data['tipe_kamar']?.toString() ?? '-';
    final String alamat = data['alamat']?.toString() ?? '-';
    final int jumlahKamar = _toInt(data['jumlah_kamar']);
    final int harga = _toInt(data['harga']);

    final double? lat = _toDouble(data['latitude']);
    final double? lng = _toDouble(data['longitude']);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOTO
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: _FotoCarousel(fotos: _kumpulkanFoto(data)),
            ),
          ),
          const SizedBox(height: 10),

          // NAMA & HARGA
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  namaKos,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatRupiah(harga),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tipe $tipe', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text('$jumlahKamar Kamar', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            alamat,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),

          // LIHAT LOKASI
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (lat == null || lng == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kost ini belum punya titik lokasi'),
                  ),
                );
                return;
              }
              _tampilkanPeta(context, namaKos, LatLng(lat, lng));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EBDD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: warnaMerah),
                  SizedBox(width: 6),
                  Text(
                    'Lihat Lokasi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kumpulkan semua foto: foto utama + foto lainnya (Base64).
  List<String> _kumpulkanFoto(Map<String, dynamic> data) {
    final List<String> hasil = [];

    final utama = data['foto_kos'];
    if (utama is String && utama.isNotEmpty) hasil.add(utama);

    final lain = data['foto_lainnya'];
    if (lain is List) {
      for (final f in lain) {
        if (f is String && f.isNotEmpty) hasil.add(f);
      }
    }

    return hasil;
  }

  // ==========================================================
  // PETA LOKASI (bottom sheet)
  // ==========================================================
  void _tampilkanPeta(BuildContext context, String nama, LatLng titik) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 380,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: warnaMerah),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: titik,
                      initialZoom: 16,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        // GANTI dengan applicationId aplikasimu.
                        userAgentPackageName: 'com.example.nama_app_kamu',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: titik,
                            width: 40,
                            height: 40,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_pin,
                              color: warnaMerah,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // UTILITAS
  // ==========================================================
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Contoh: Rp. 500.000
  static String _formatRupiah(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final sisa = text.length - i;
      buffer.write(text[i]);
      if (sisa > 1 && sisa % 3 == 1) buffer.write('.');
    }

    return 'Rp. ${buffer.toString()}';
  }
}


// ============================================================
// CAROUSEL FOTO (geser kiri/kanan + titik + panah)
// ============================================================
class _FotoCarousel extends StatefulWidget {
  final List<String> fotos;

  const _FotoCarousel({required this.fotos});

  @override
  State<_FotoCarousel> createState() => _FotoCarouselState();
}

class _FotoCarouselState extends State<_FotoCarousel> {
  // Jeda antar foto saat slide otomatis.
  static const Duration _jedaOtomatis = Duration(seconds: 3);

  final PageController _controller = PageController();
  List<Uint8List?> _bytes = [];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _decode();
    _mulaiOtomatis();
  }

  // Geser otomatis ke foto berikutnya, kembali ke awal setelah foto terakhir.
  void _mulaiOtomatis() {
    _timer?.cancel();
    if (_bytes.length < 2) return;

    _timer = Timer.periodic(_jedaOtomatis, (_) {
      if (!mounted || !_controller.hasClients || _bytes.length < 2) return;

      final int berikutnya = (_index + 1) % _bytes.length;
      _controller.animateToPage(
        berikutnya,
        duration: Duration(milliseconds: berikutnya == 0 ? 600 : 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _hentikanOtomatis() => _timer?.cancel();

  @override
  void didUpdateWidget(covariant _FotoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fotos.length != widget.fotos.length ||
        (widget.fotos.isNotEmpty &&
            oldWidget.fotos.isNotEmpty &&
            oldWidget.fotos.first != widget.fotos.first)) {
      _decode();
      if (_controller.hasClients) _controller.jumpToPage(0);
      _mulaiOtomatis();
    }
  }

  // Decode sekali saja agar tidak berat saat di-scroll.
  void _decode() {
    _bytes = widget.fotos.map((b64) {
      try {
        return base64Decode(b64);
      } catch (_) {
        return null;
      }
    }).toList();
    _index = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _pindah(int ke) {
    if (ke < 0 || ke >= _bytes.length) return;
    _controller.animateToPage(
      ke,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF4F4F4),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _panah(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes.isEmpty) return _placeholder();

    // Slide berhenti sementara saat foto disentuh/digeser,
    // lalu lanjut otomatis lagi setelah dilepas.
    return Listener(
      onPointerDown: (_) => _hentikanOtomatis(),
      onPointerUp: (_) => _mulaiOtomatis(),
      onPointerCancel: (_) => _mulaiOtomatis(),
      child: Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: _bytes.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            final data = _bytes[i];
            if (data == null) return _placeholder();
            return Image.memory(
              data,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _placeholder(),
            );
          },
        ),

        if (_bytes.length > 1) ...[
          // Panah kiri
          if (_index > 0)
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: _panah(Icons.chevron_left, () => _pindah(_index - 1)),
              ),
            ),

          // Panah kanan
          if (_index < _bytes.length - 1)
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: _panah(Icons.chevron_right, () => _pindah(_index + 1)),
              ),
            ),

          // Titik indikator
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bytes.length, (i) {
                final aktif = i == _index;
                return Container(
                  width: aktif ? 8 : 6,
                  height: aktif ? 8 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: aktif ? Colors.white : Colors.white54,
                  ),
                );
              }),
            ),
          ),
        ],
      ],
      ),
    );
  }
}