import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/bg_abang.dart';

class KamarPage extends StatelessWidget {
  final String kostId;
  final String namaKos;

  /// Foto utama kost (Base64), dipakai sebagai foto di setiap kamar.
  final String? fotoBase64;

  const KamarPage({
    super.key,
    required this.kostId,
    required this.namaKos,
    this.fotoBase64,
  });

  static const Color warnaMerah = Color(0xFF9E182B);
  static const Color warnaTerisi = Color(0xFFF8E7EA);

  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    final double tinggiHeader = statusBar + 18 + 48 + 8;

    // Decode foto sekali saja, dipakai ulang di setiap kartu.
    final Uint8List? fotoBytes = _decodeFoto(fotoBase64);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER MERAH
          BackgroundMerah(
            radius: 0,
            height: tinggiHeader,
            child: Padding(
              padding: EdgeInsets.only(top: statusBar),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(-12, 0),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      namaKos,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // DAFTAR KAMAR
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kost')
                  .doc(kostId)
                  .collection('kamar')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: warnaMerah),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = [...(snapshot.data?.docs ?? [])];

                // Urutkan berdasarkan nomor kamar
                docs.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                  return _toInt(da['nomor_kamar'])
                      .compareTo(_toInt(db['nomor_kamar']));
                });

                if (docs.isEmpty) return _buildKosong();

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    12,
                    14,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildKartuKamar(context, data, fotoBytes);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // KARTU KAMAR
  // ==========================================================
  Widget _buildKartuKamar(
    BuildContext context,
    Map<String, dynamic> data,
    Uint8List? fotoBytes,
  ) {
    final String namaKamar = data['nama_kamar']?.toString() ?? '-';
    final String status = data['status']?.toString().toLowerCase() ?? 'kosong';
    final bool terisi = status == 'terisi';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: terisi ? warnaTerisi : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOTO
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: fotoBytes == null
                  ? Container(
                      color: const Color(0xFFF4F4F4),
                      child: Icon(
                        Icons.bed_outlined,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                    )
                  : Image.memory(
                      fotoBytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // NAMA KOST, KAMAR, TOMBOL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaKos,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.vpn_key_outlined, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        namaKamar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () => _lihatPenghuni(context, namaKamar, terisi),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lihat Data Penghuni',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LIHAT DATA PENGHUNI
  // ==========================================================
  void _lihatPenghuni(BuildContext context, String namaKamar, bool terisi) {
    // TODO: ganti dengan halaman data penghuni kamar ini.
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(namaKamar),
        content: Text(
          terisi
              ? 'Data penghuni belum tersedia.'
              : 'Kamar ini masih kosong.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: warnaMerah)),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TAMPILAN KOSONG
  // ==========================================================
  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.door_front_door_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada kamar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // UTILITAS
  // ==========================================================
  static Uint8List? _decodeFoto(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}