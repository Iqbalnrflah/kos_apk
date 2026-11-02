import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/bg_abang.dart';

class notifPage extends StatelessWidget {
  const notifPage({super.key});

  static const Color warnaMerah = Color(0xFF9E182B);

  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    final double bawah = MediaQuery.of(context).padding.bottom;
    final double tinggiHeader = statusBar + 18 + 48 + 8;

    final String? ownerId = FirebaseAuth.instance.currentUser?.uid;

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
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // DAFTAR NOTIFIKASI
          Expanded(
            child: ownerId == null
                ? const Center(child: Text('Silakan login terlebih dahulu'))
                : StreamBuilder<QuerySnapshot>(
                    // Tanpa orderBy agar tidak butuh composite index;
                    // pengurutan dilakukan di bawah.
                    stream: FirebaseFirestore.instance
                        .collection('pembayaran')
                        .where('ownerId', isEqualTo: ownerId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: warnaMerah,
                          ),
                        );
                      }

                      final List<_Notif> daftar = _susunNotifikasi(
                        snapshot.data!.docs,
                      );

                      if (daftar.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada notifikasi',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          14,
                          14,
                          14,
                          14 + bawah,
                        ),
                        itemCount: daftar.length,
                        itemBuilder: (context, index) {
                          return _buildKartu(daftar[index]);
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
  // SUSUN NOTIFIKASI DARI DATA PEMBAYARAN
  // ==========================================================
  static List<_Notif> _susunNotifikasi(List<QueryDocumentSnapshot> docs) {
    final List<_Notif> hasil = [];
    final DateTime sekarang = DateTime.now();

    for (final doc in docs) {
      final item = doc.data() as Map<String, dynamic>;

      final String nama = item['penghuni_nama']?.toString() ?? '-';
      final String metode = item['metode']?.toString() ?? '';
      final String status = item['status']?.toString().toLowerCase() ?? '';

      final dynamic tglBayar = item['tanggal_bayar'];
      final dynamic jatuhTempo = item['jatuh_tempo'];

      // 1) JATUH TEMPO: belum lunas dan sudah lewat / kurang dari 7 hari lagi.
      if (status != 'lunas' && jatuhTempo is Timestamp) {
        final DateTime tanggal = jatuhTempo.toDate();

        if (tanggal.difference(sekarang).inDays <= 7) {
          final int sisa = _toInt(item['sisa_tagihan']);

          hasil.add(
            _Notif(
              judul: 'Jatuh Tempo',
              nama: nama,
              metode: '',
              nominal: sisa > 0 ? sisa : _toInt(item['jumlah_bayar']),
              waktu: tanggal,
            ),
          );
        }
        continue;
      }

      // 2) SUDAH DIBAYAR: dana masuk / konfirmasi pembayaran tunai.
      if (tglBayar is Timestamp) {
        final String m = metode.toLowerCase();
        final bool tunai = m.contains('cash') || m.contains('tunai');

        hasil.add(
          _Notif(
            judul: tunai ? 'Konfirmasi Pembayaran Berhasil' : 'Dana masuk',
            nama: nama,
            metode: metode.isEmpty ? '-' : metode,
            nominal: _toInt(item['jumlah_bayar']),
            waktu: tglBayar.toDate(),
          ),
        );
      }
    }

    // Terbaru di atas
    hasil.sort((a, b) => b.waktu.compareTo(a.waktu));
    return hasil;
  }

  // ==========================================================
  // KARTU NOTIFIKASI
  // ==========================================================
  Widget _buildKartu(_Notif n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KIRI: judul, nama, metode
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(n.nama, style: const TextStyle(fontSize: 13)),
                if (n.metode.isNotEmpty)
                  Text(n.metode, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // KANAN: tanggal dan nominal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTanggal(n.waktu),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                _formatRupiah(n.nominal),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // UTILITAS
  // ==========================================================
  static String _formatTanggal(DateTime t) {
    String dua(int v) => v.toString().padLeft(2, '0');
    return '${dua(t.day)}/${dua(t.month)}/${t.year} . ${dua(t.hour)}:${dua(t.minute)}';
  }

  // Contoh: Rp.100.000
  static String _formatRupiah(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final sisa = text.length - i;
      buffer.write(text[i]);
      if (sisa > 1 && sisa % 3 == 1) buffer.write('.');
    }

    return 'Rp.${buffer.toString()}';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

// Satu baris notifikasi yang sudah disusun.
class _Notif {
  final String judul;
  final String nama;
  final String metode;
  final int nominal;
  final DateTime waktu;

  const _Notif({
    required this.judul,
    required this.nama,
    required this.metode,
    required this.nominal,
    required this.waktu,
  });
}