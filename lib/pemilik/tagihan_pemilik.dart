
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../penghuni/detail_tagihan.dart';

const Color warnaMerah = Color(0xFF9E182B);

// ==========================================
// HALAMAN 1: DAFTAR KOST PEMILIK
// ==========================================

class TagihanPemilikPage extends StatefulWidget {
  const TagihanPemilikPage({super.key});

  @override
  State<TagihanPemilikPage> createState() =>
      _TagihanPemilikPageState();
}

class _TagihanPemilikPageState
    extends State<TagihanPemilikPage> {
  final TextEditingController searchController =
      TextEditingController();

  String keyword = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget gambarKos(String? foto) {
    if (foto == null || foto.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.home_work,
          size: 40,
          color: Colors.grey,
        ),
      );
    }

    try {
      String bersih = foto.contains(',')
          ? foto.split(',').last
          : foto;

      return Image.memory(
        base64Decode(bersih),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.home_work,
          size: 40,
        ),
      );
    } catch (e) {
      return const Icon(Icons.home_work);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User belum login')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 45,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            color: warnaMerah,
            child: const Center(
              child: Text(
                'TAGIHAN PEMILIK KOST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  keyword = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari Tagihan Disini',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    searchController.clear();
                    setState(() => keyword = '');
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          // DAFTAR KOST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kost')
                  .where('owner_id', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final kostList = snapshot.data!.docs.where((doc) {
                  final item =
                      doc.data() as Map<String, dynamic>;

                  final nama =
                      (item['nama_kos'] ?? '').toString();

                  return nama.toLowerCase().contains(keyword);
                }).toList();

                if (kostList.isEmpty) {
                  return const Center(
                    child: Text('Kost tidak ditemukan'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  itemCount: kostList.length,
                  itemBuilder: (context, index) {
                    final doc = kostList[index];
                    final item =
                        doc.data() as Map<String, dynamic>;

                    final nama =
                        item['nama_kos'] ?? '-';

                    final alamat =
                        item['alamat'] ?? '-';

                    final foto =
                        item['foto_kos']?.toString();

                    return StreamBuilder<QuerySnapshot>(
                      stream: doc.reference
                          .collection('kamar')
                          .snapshots(),
                      builder: (context, kamarSnapshot) {
                        int jumlahTagihan = 0;

                        if (kamarSnapshot.hasData) {
                          jumlahTagihan =
                              kamarSnapshot.data!.docs.where((kamar) {
                            final data =
                                kamar.data()
                                    as Map<String, dynamic>;

                            final penghuni =
                                data['penghuniId'];

                            return penghuni != null &&
                                penghuni.toString().isNotEmpty &&
                                data['status_pembayaran'] !=
                                    'Lunas';
                          }).length;
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DaftarPenghuniKosPage(
                                  kosId: doc.id,
                                  namaKos: nama.toString(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 9,
                            ),
                            height: 91,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // FOTO KOST
                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  child: SizedBox(
                                    width: 85,
                                    height: double.infinity,
                                    child: gambarKos(foto),
                                  ),
                                ),

                                // INFORMASI KOST
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                nama.toString(),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color: warnaMerah,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5),
                                              ),
                                              child: Text(
                                                '$jumlahTagihan tagihan',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          alamat.toString(),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

// ==========================================
// HALAMAN 2: DAFTAR PENGHUNI PER KOST
// ==========================================

class DaftarPenghuniKosPage extends StatefulWidget {
  final String kosId;
  final String namaKos;

  const DaftarPenghuniKosPage({
    super.key,
    required this.kosId,
    required this.namaKos,
  });

  @override
  State<DaftarPenghuniKosPage> createState() =>
      _DaftarPenghuniKosPageState();
}

class _DaftarPenghuniKosPageState
    extends State<DaftarPenghuniKosPage> {
  final TextEditingController searchController =
      TextEditingController();

  String keyword = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatTanggal(dynamic tanggal) {
    if (tanggal is Timestamp) {
      final date = tanggal.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 42,
              bottom: 15,
              left: 12,
              right: 12,
            ),
            color: warnaMerah,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.namaKos.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 45),
              ],
            ),
          ),

          // JUDUL
          const Padding(
            padding: EdgeInsets.only(
              left: 15,
              top: 12,
              bottom: 5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Penghuni',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  keyword = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari Penghuni Disini',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // DATA PENGHUNI
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kost')
                  .doc(widget.kosId)
                  .collection('kamar')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final penghuni = snapshot.data!.docs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  final uid = data['penghuniId'];

                  final nama =
                      (data['penghuni_nama'] ?? '')
                          .toString()
                          .toLowerCase();

                  return uid != null &&
                      uid.toString().isNotEmpty &&
                      nama.contains(keyword);
                }).toList();

                if (penghuni.isEmpty) {
                  return const Center(
                    child: Text('Belum ada penghuni'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  itemCount: penghuni.length,
                  itemBuilder: (context, index) {
                    final doc = penghuni[index];

                    final item =
                        doc.data() as Map<String, dynamic>;

                    final nama =
                        item['penghuni_nama'] ?? '-';

                    final namaKamar =
                        item['nama_kamar'] ?? '-';

                    final kamarId = doc.id;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          // FOTO PROFIL
                          CircleAvatar(
                            radius: 19,
                            backgroundColor:
                                Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),

                          const SizedBox(width: 10),

                          // NAMA DAN KAMAR
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama.toString(),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.key_outlined,
                                      size: 17,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      namaKamar.toString(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // DETAIL TAGIHAN
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailTagihanPage(
                                    data: item,
                                    kosId: widget.kosId,
                                    kamarId: kamarId,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Lihat Detail Tagihan',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
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
