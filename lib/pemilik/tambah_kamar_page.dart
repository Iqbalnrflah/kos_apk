import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/bg_abang.dart';

class TambahKamarPage extends StatefulWidget {
  const TambahKamarPage({super.key});

  @override
  State<TambahKamarPage> createState() => _TambahKamarPageState();
}

class _TambahKamarPageState extends State<TambahKamarPage> {
  static const Color warnaMerah = Color(0xFF9E182B);
  static const LatLng _titikAwal = LatLng(-7.3274, 108.2207);

  // Foto disimpan sebagai Base64 di dokumen Firestore (maks. 1 MiB per
  // dokumen), jadi jumlah dan total ukuran foto dibatasi.
  static const int _maksFoto = 5;
  static const int _maksTotalBase64 = 900 * 1000; // karakter Base64

  bool isLoading = false;
  bool isLoadingLokasi = false;

  final pemilik = TextEditingController();
  final namaKos = TextEditingController();
  final jumlahKamar = TextEditingController();
  final alamat = TextEditingController();
  final harga = TextEditingController();
  final tipeKamar = TextEditingController();

  final MapController mapController = MapController();
  LatLng? titikLokasi;

  // Foto pertama = foto utama.
  final List<XFile> fotoKos = [];

  @override
  void dispose() {
    pemilik.dispose();
    namaKos.dispose();
    jumlahKamar.dispose();
    alamat.dispose();
    harga.dispose();
    tipeKamar.dispose();
    mapController.dispose();
    super.dispose();
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  // =========================
  // PILIH FOTO KOST (BANYAK)
  // =========================
  Future<void> pilihFotoKos() async {
    final int sisa = _maksFoto - fotoKos.length;

    if (sisa <= 0) {
      _snack('Maksimal $_maksFoto foto');
      return;
    }

    try {
      final List<XFile> gambar = await ImagePicker().pickMultiImage(
        imageQuality: 40,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (gambar.isEmpty || !mounted) return;

      setState(() => fotoKos.addAll(gambar.take(sisa)));

      if (gambar.length > sisa) {
        _snack('Hanya $sisa foto yang ditambahkan (maksimal $_maksFoto foto)');
      }
    } catch (e) {
      _snack('Gagal memilih foto: $e');
    }
  }

  void _hapusFoto(int index) {
    setState(() => fotoKos.removeAt(index));
  }

  // =========================
  // TAMBAH KOST DAN KAMAR
  // =========================
  Future<void> tambahKamar() async {
    if (isLoading) return;

    if (pemilik.text.trim().isEmpty ||
        namaKos.text.trim().isEmpty ||
        tipeKamar.text.trim().isEmpty ||
        jumlahKamar.text.trim().isEmpty ||
        alamat.text.trim().isEmpty ||
        harga.text.trim().isEmpty) {
      _snack('Semua field wajib diisi');
      return;
    }

    if (fotoKos.isEmpty) {
      _snack('Silakan pilih minimal 1 foto kost');
      return;
    }

    final int? totalKamar = int.tryParse(jumlahKamar.text.trim());
    final int? hargaKos = int.tryParse(harga.text.trim());

    if (totalKamar == null ||
        totalKamar <= 0 ||
        hargaKos == null ||
        hargaKos <= 0) {
      _snack('Jumlah kamar dan harga harus berupa angka positif');
      return;
    }

    // Firestore batch maksimal 500 operasi.
    if (totalKamar > 499) {
      _snack('Jumlah kamar maksimal 499 sekaligus');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('Silakan login terlebih dahulu');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Ubah semua foto menjadi Base64.
      final List<String> semuaFoto = [];
      int totalKarakter = 0;

      for (final foto in fotoKos) {
        final bytes = await foto.readAsBytes();
        final b64 = base64Encode(bytes);
        totalKarakter += b64.length;
        semuaFoto.add(b64);
      }

      if (totalKarakter > _maksTotalBase64) {
        throw Exception(
          'Total ukuran foto terlalu besar. '
          'Kurangi jumlah foto atau pilih foto yang lebih kecil.',
        );
      }

      final kosRef =
          await FirebaseFirestore.instance.collection('kost').add({
        'pemilik': pemilik.text.trim(),
        'nama_kos': namaKos.text.trim(),
        'owner_id': user.uid,
        'tipe_kamar': tipeKamar.text.trim(),
        'jumlah_kamar': totalKamar,
        'alamat': alamat.text.trim(),
        'latitude': titikLokasi?.latitude,
        'longitude': titikLokasi?.longitude,
        'harga': hargaKos,
        // Foto utama (kompatibel dengan kode lama)
        'foto_kos': semuaFoto.first,
        // Foto lainnya (setelah foto utama)
        'foto_lainnya': semuaFoto.skip(1).toList(),
        'created_at': Timestamp.now(),
      });

      final batch = FirebaseFirestore.instance.batch();

      for (int i = 1; i <= totalKamar; i++) {
        final kamarRef = kosRef.collection('kamar').doc();
        batch.set(kamarRef, {
          'nama_kamar': 'Kamar $i',
          'nomor_kamar': i,
          'status': 'kosong',
        });
      }

      await batch.commit();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            content: const Text(
              'Kos dan kamar berhasil dibuat',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warnaMerah,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _snack('Gagal menambahkan kost: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // =========================
  // KOORDINAT -> ALAMAT
  // =========================
  Future<void> isiAlamatDariKoordinat(double lat, double lng) async {
    final hasil = await geocoding.Geocoding().placemarkFromCoordinates(
      lat,
      lng,
    );

    if (hasil.isEmpty) throw Exception('Alamat tidak ditemukan');

    final lokasi = hasil.first;

    final bagianAlamat = [
      lokasi.street,
      lokasi.subLocality,
      lokasi.locality,
      lokasi.subAdministrativeArea,
      lokasi.administrativeArea,
      lokasi.postalCode,
    ].where((b) => b != null && b.trim().isNotEmpty).toSet().toList();

    if (bagianAlamat.isEmpty) throw Exception('Alamat tidak ditemukan');

    if (!mounted) return;
    setState(() => alamat.text = bagianAlamat.join(', '));
  }

  // =========================
  // AMBIL LOKASI GPS
  // =========================
  Future<void> ambilLokasi() async {
    if (isLoadingLokasi) return;

    setState(() => isLoadingLokasi = true);

    try {
      final bool serviceAktif =
          await geo.Geolocator.isLocationServiceEnabled();

      if (!serviceAktif) {
        _snack('GPS belum aktif. Aktifkan GPS lalu coba lagi.');
        await geo.Geolocator.openLocationSettings();
        return;
      }

      geo.LocationPermission izin = await geo.Geolocator.checkPermission();

      if (izin == geo.LocationPermission.denied) {
        izin = await geo.Geolocator.requestPermission();
      }

      if (izin == geo.LocationPermission.denied ||
          izin == geo.LocationPermission.deniedForever) {
        _snack('Izin lokasi diperlukan untuk mengambil alamat.');
        return;
      }

      final geo.Position posisi = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      final titik = LatLng(posisi.latitude, posisi.longitude);

      if (!mounted) return;
      setState(() => titikLokasi = titik);
      mapController.move(titik, 17);

      await isiAlamatDariKoordinat(posisi.latitude, posisi.longitude);
    } catch (e) {
      _snack('Gagal mengambil lokasi: $e');
    } finally {
      if (mounted) setState(() => isLoadingLokasi = false);
    }
  }

  // =========================
  // KETUK PETA
  // =========================
  Future<void> _onTapPeta(LatLng titik) async {
    setState(() => titikLokasi = titik);

    try {
      await isiAlamatDariKoordinat(titik.latitude, titik.longitude);
    } catch (e) {
      _snack('Gagal mengambil alamat: $e');
    }
  }

  // =========================
  // WIDGET BANTU
  // =========================
  Widget _labelForm(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        teks,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildInput(
    TextEditingController controller,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: warnaMerah, width: 1.5),
          ),
        ),
      ),
    );
  }

  // =========================
  // FOTO KOST (BANYAK)
  // =========================
  Widget _buildFotoKos() {
    const double ukuran = 110;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Foto Kost',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '${fotoKos.length}/$_maksFoto',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: ukuran,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount:
                fotoKos.length + (fotoKos.length < _maksFoto ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              // Tombol tambah foto (selalu di posisi pertama)
              if (index == 0 && fotoKos.length < _maksFoto) {
                return _buildTombolTambahFoto(ukuran);
              }

              final int i =
                  fotoKos.length < _maksFoto ? index - 1 : index;

              return _buildThumbFoto(i, ukuran);
            },
          ),
        ),
        if (fotoKos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Foto pertama menjadi foto utama kost',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildTombolTambahFoto(double ukuran) {
    return GestureDetector(
      onTap: isLoading ? null : pilihFotoKos,
      child: Container(
        width: ukuran,
        height: ukuran,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 28, color: warnaMerah),
            SizedBox(height: 8),
            Text('Tambah Foto', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbFoto(int i, double ukuran) {
    return SizedBox(
      width: ukuran,
      height: ukuran,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(fotoKos[i].path), fit: BoxFit.cover),
          ),

          // Label foto utama
          if (i == 0)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: warnaMerah,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Utama',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Tombol hapus
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: isLoading ? null : () => _hapusFoto(i),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJumlahKamar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30),
            onPressed: isLoading
                ? null
                : () {
                    final jumlah = int.tryParse(jumlahKamar.text) ?? 1;
                    if (jumlah > 1) {
                      setState(() => jumlahKamar.text = '${jumlah - 1}');
                    }
                  },
            icon: const Icon(Icons.remove, size: 18),
          ),
          Flexible(
            child: TextField(
              controller: jumlahKamar,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '0',
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30),
            onPressed: isLoading
                ? null
                : () {
                    final jumlah = int.tryParse(jumlahKamar.text) ?? 0;
                    setState(() => jumlahKamar.text = '${jumlah + 1}');
                  },
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPeta() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: titikLokasi ?? _titikAwal,
            initialZoom: 15,
            onTap: (tapPosition, titik) => _onTapPeta(titik),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // GANTI dengan applicationId aplikasimu
              // (lihat android/app/build.gradle).
              userAgentPackageName: 'com.example.nama_app_kamu',
            ),
            if (titikLokasi != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: titikLokasi!,
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
    );
  }

  // =========================
  // TAMPILAN HALAMAN
  // =========================
  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    final double bawah = MediaQuery.of(context).padding.bottom;
    final double topForm = statusBar + 135;
    final double tinggiHeader = topForm + 75;

    return Scaffold(
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
                            'Tambah Kost',
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
                      'Tambahkan Data Kost\nAnda Di Sini !',
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

            // FORM PUTIH
            Positioned(
              top: topForm,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bawah),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFotoKos(),
                      const SizedBox(height: 14),

                      _labelForm('Nama Pemilik'),
                      buildInput(pemilik, 'masukan nama pemilik kost'),

                      _labelForm('Nama Kost'),
                      buildInput(namaKos, 'masukan nama kost anda'),

                      _labelForm('Tipe Kamar'),
                      buildInput(tipeKamar, 'masukan tipe kamar'),

                      // TARIF DAN JUMLAH KAMAR
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _labelForm('Tarif Kost'),
                                buildInput(
                                  harga,
                                  'Rp.0',
                                  keyboard: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _labelForm('Jumlah Kamar'),
                                _buildJumlahKamar(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // ALAMAT (otomatis dari GPS/peta, bisa diedit manual)
                      _labelForm('Alamat Kost'),
                      TextField(
                        controller: alamat,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Ketuk peta atau tambahkan lokasi',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: warnaMerah,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // TOMBOL AMBIL LOKASI
                      InkWell(
                        onTap: isLoadingLokasi ? null : ambilLokasi,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: warnaMerah,
                                size: 21,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isLoadingLokasi
                                    ? 'Mengambil lokasi...'
                                    : 'Tambahkan Lokasi',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (isLoadingLokasi)
                                const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: warnaMerah,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // PETA
                      _buildPeta(),

                      const SizedBox(height: 16),

                      // TOMBOL SELESAI
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : tambahKamar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: warnaMerah,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Selesai',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}