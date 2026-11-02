import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/bg_abang.dart';
import 'kos.dart';
import 'notifikasi_page.dart';
import 'kamar/kamar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color warnaMerah = Color(0xFF9E182B);

  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    const double jarakHeader = 12;
    final double topKonten = statusBar + jarakHeader + 18 + 48 + 10;
    final double tinggiHeader = topKonten + 120;

    // Hanya data milik akun yang sedang login yang ditampilkan.
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Silakan login terlebih dahulu'));
    }

    return StreamBuilder<QuerySnapshot>(
      // KOST MILIK AKUN INI
      stream: FirebaseFirestore.instance
          .collection('kost')
          .where('owner_id', isEqualTo: uid)
          .snapshots(),
      builder: (context, kostSnapshot) {
        if (kostSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: warnaMerah),
          );
        }

        if (kostSnapshot.hasError) {
          return Center(child: Text('Error: ${kostSnapshot.error}'));
        }

        final kostDocs = kostSnapshot.data?.docs ?? [];

        // TOTAL KOS & KAMAR
        final int totalKos = kostDocs.length;
        int totalKamar = 0;
        for (final doc in kostDocs) {
          final data = doc.data() as Map<String, dynamic>;
          totalKamar += _toInt(data['jumlah_kamar']);
        }

        // ID semua kost milik akun ini (untuk menyaring pembayaran)
        final Set<String> kostIds = kostDocs.map((d) => d.id).toSet();

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('pembayaran').snapshots(),
          builder: (context, pembayaranSnapshot) {
            // PEMBAYARAN MILIK AKUN INI SAJA
            // Sesuaikan nama field 'owner_id' / 'kost_id' dengan data kamu.
            final pembayaranDocs =
                (pembayaranSnapshot.data?.docs ?? []).where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return d['owner_id'] == uid || kostIds.contains(d['kost_id']);
            }).toList();

            int kamarLunas = 0;
            int belumBayar = 0;
            int jumlahSudahBayar = 0;
            int jumlahBelumBayar = 0;
            int terlambat = 0;
            int segeraJatuhTempo = 0;
            final now = DateTime.now();

            for (final doc in pembayaranDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status']?.toString().toLowerCase() ?? '';
              final jumlah = _toInt(data['jumlah_bayar']);
              final sisa = _toInt(data['sisa_tagihan']);

              if (status == 'lunas') {
                kamarLunas++;
                jumlahSudahBayar += jumlah;
              } else {
                belumBayar++;
                jumlahBelumBayar += sisa;
              }

              final jatuhTempo = data['jatuh_tempo'];
              if (jatuhTempo is Timestamp && status != 'lunas') {
                final selisih = jatuhTempo.toDate().difference(now).inDays;
                if (selisih < 0) {
                  terlambat++;
                } else if (selisih <= 7) {
                  segeraJatuhTempo++;
                }
              }
            }

            final bool adaTagihan = pembayaranDocs.isNotEmpty;

            // PENGHUNI MILIK AKUN INI
            // Butuh field 'owner_id' di dokumen penghuni (tabel users).
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'penghuni')
                  .where('owner_id', isEqualTo: uid)
                  .snapshots(),
              builder: (context, penghuniSnapshot) {
                final int totalPenghuni =
                    penghuniSnapshot.data?.docs.length ?? 0;

                return SingleChildScrollView(
                  child: Stack(
                    children: [
                      // HEADER MERAH
                      BackgroundMerah(
                        height: tinggiHeader,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: statusBar + jarakHeader),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              height: 48,
                              child: _buildHeader(context),
                            ),
                          ),
                        ),
                      ),

                      // KONTEN
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, topKonten, 16, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildKartuTagihan(
                              jumlahSudahBayar: jumlahSudahBayar,
                              jumlahBelumBayar: jumlahBelumBayar,
                              kamarLunas: kamarLunas,
                              belumBayar: belumBayar,
                              adaTagihan: adaTagihan,
                            ),

                            const SizedBox(height: 20),
                            _judulSection('Rincian'),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildRincianCard(
                                    icon: Icons.home_outlined,
                                    iconColor: Colors.blue,
                                    iconBackground: Colors.blue.shade50,
                                    value: totalKos.toString(),
                                    label: 'Kos',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DaftarKostPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildRincianCard(
                                    icon: Icons.door_front_door_outlined,
                                    iconColor: Colors.cyan,
                                    iconBackground: Colors.cyan.shade50,
                                    value: totalKamar.toString(),
                                    label: 'Kamar',
                                    onTap: () {
                                      if (kostDocs.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Belum ada kost')),
                                        );
                                        return;
                                      }
                                    
                                      if (kostDocs.length == 1) {
                                        final doc = kostDocs.first;
                                        final data = doc.data() as Map<String, dynamic>;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => KamarPage(
                                              kostId: doc.id,
                                              namaKos: data['nama_kos']?.toString() ?? 'Kost',
                                              fotoBase64: data['foto_kos']?.toString(),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const DaftarKostPage()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            _buildKelolaPenghuni(totalPenghuni),
                            const SizedBox(height: 20),
                            _judulSection('Perlu Perhatian'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPerhatianCard(
                                    icon: Icons.error_outline,
                                    value: terlambat,
                                    label: 'Terlambat',
                                    color: Colors.black87,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                Expanded(
                                  child: _buildPerhatianCard(
                                    icon: Icons.error_outline,
                                    value: terlambat,
                                    label: 'Tunggakan',
                                    color: Colors.black87,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildPerhatianCard(
                                    icon: Icons.schedule_outlined,
                                    value: segeraJatuhTempo,
                                    label: 'Segera Jatuh Tempo',
                                    color: Colors.deepOrange,
                                    backgroundColor: const Color(0xFFFFF2EC),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // HEADER (logo, sapaan, ikon)
  // ==========================================================
  Widget _buildHeader(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/img/LogoPay.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: uid == null
              ? _teksSapaan('')
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data =
                        snapshot.data?.data() as Map<String, dynamic>?;
                    final nama = data?['nama']?.toString() ?? '';
                    return _teksSapaan(nama);
                  },
                ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.support_agent, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => notifPage()),
            );
          },
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _teksSapaan(String nama) {
    return Text(
      'Selamat Datang,\n$nama',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    );
  }

  Widget _judulSection(String teks) {
    return Text(
      teks,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  // ==========================================================
  // KARTU TAGIHAN (putih, menumpuk di atas header)
  // ==========================================================
  Widget _buildKartuTagihan({
    required int jumlahSudahBayar,
    required int jumlahBelumBayar,
    required int kamarLunas,
    required int belumBayar,
    required bool adaTagihan,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judulSection('Tagihan Sewa Bulan Ini'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTagihanCard(
                  title: 'Sudah Bayar',
                  nominal: jumlahSudahBayar,
                  detail: adaTagihan
                      ? '$kamarLunas Kamar Lunas'
                      : 'Belum ada tagihan',
                  backgroundColor: const Color(0xFFE2FFE1),
                  accentColor: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTagihanCard(
                  title: 'Belum Bayar',
                  nominal: jumlahBelumBayar,
                  detail: !adaTagihan
                      ? 'Belum ada tagihan'
                      : (belumBayar == 0
                          ? 'Semua Kamar Lunas'
                          : '$belumBayar Kamar Belum Bayar'),
                  backgroundColor: const Color(0xFFF8E7EA),
                  accentColor: warnaMerah,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagihanCard({
    required String title,
    required int nominal,
    required String detail,
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: accentColor, size: 22),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(nominal),
              style: TextStyle(
                color: accentColor,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CARD RINCIAN
  // ==========================================================
  Widget _buildRincianCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 105,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 25),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // KELOLA DATA PENGHUNI
  // ==========================================================
  Widget _buildKelolaPenghuni(int totalPenghuni) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: buka halaman data penghuni
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.people_outline, size: 22),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Kelola Data Penghuni',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: warnaMerah,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalPenghuni Penghuni',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              totalPenghuni == 0
                  ? 'Belum ada Penghuni'
                  : '$totalPenghuni penghuni terdaftar',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CARD PERLU PERHATIAN
  // ==========================================================
  Widget _buildPerhatianCard({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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

  // Format Rupiah tanpa package intl, contoh: Rp 1.500.000
  static String _formatRupiah(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final sisa = text.length - i;
      buffer.write(text[i]);
      if (sisa > 1 && sisa % 3 == 1) buffer.write('.');
    }

    return 'Rp ${buffer.toString()}';
  }
}