
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/header.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  static const Color warnaMerah = Color(0xFF9E182B);

  // Mengambil tanggal dari Firebase
  DateTime? ambilTanggal(Map<String, dynamic> item) {
    final tanggal = item['updated_at'] ?? item['tanggal_bayar'];

    if (tanggal is Timestamp) {
      return tanggal.toDate();
    }

    if (tanggal is DateTime) {
      return tanggal;
    }

    return null;
  }

  // Format tanggal dan jam
  String formatTanggal(DateTime? tanggal) {
    if (tanggal == null) {
      return 'Menunggu Pembayaran';
    }

    return '${tanggal.day.toString().padLeft(2, '0')}/'
        '${tanggal.month.toString().padLeft(2, '0')}/'
        '${tanggal.year} • '
        '${tanggal.hour.toString().padLeft(2, '0')}:'
        '${tanggal.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User belum login'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FC),

      body: Column(
        children: [
          // HEADER
          const CustomHeader(title: 'Riwayat'),

          // DATA RIWAYAT
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('pembayaran')
                  .where(
                    'ownerId',
                    isEqualTo: user.uid,
                  )
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada riwayat pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                // Ambil seluruh data pembayaran
                final data = snapshot.data!.docs.toList();

                // Urutkan berdasarkan waktu terbaru
                data.sort((a, b) {
                  final aData =
                      a.data() as Map<String, dynamic>;

                  final bData =
                      b.data() as Map<String, dynamic>;

                  final aTanggal =
                      ambilTanggal(aData);

                  final bTanggal =
                      ambilTanggal(bData);

                  if (aTanggal == null) return 1;
                  if (bTanggal == null) return -1;

                  return bTanggal.compareTo(aTanggal);
                });

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    12, 10, 12, 20,
                  ),

                  itemCount: data.length,

                  itemBuilder: (context, index) {

                    final item =
                        data[index].data()
                            as Map<String, dynamic>;

                    // DATA FIREBASE
                    final String nama =
                        item['penghuni_nama'] ?? '-';

                    final String namaKos =
                        item['nama_kos'] ?? '-';

                    final String namaKamar =
                        item['nama_kamar'] ?? '-';

                    final String status =
                        (item['status'] ?? 'Belum Lunas')
                            .toString();

                    final tanggal =
                        ambilTanggal(item);

                    final String tanggalText =
                        formatTanggal(tanggal);

                    final bool isLunas =
                        status.toLowerCase() == 'lunas';

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 9,
                      ),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(10),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.16),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // BARIS NAMA DAN TANGGAL
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Expanded(
                                child: Text(
                                  nama,

                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 5),

                              Text(
                                tanggalText,

                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          // NAMA KOST
                          Text(
                            namaKos,

                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                            ),
                          ),

                          // BARIS KAMAR DAN STATUS
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                            children: [

                              Text(
                                namaKamar,

                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),

                              // STATUS PEMBAYARAN
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: warnaMerah,
                                  borderRadius:
                                      BorderRadius.circular(5),
                                ),

                                child: Text(
                                  isLunas
                                      ? 'Lunas'
                                      : 'Belum Lunas',

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
