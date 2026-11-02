import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kospay_dart/pemilik/kamar/kamar.dart';
import 'package:kospay_dart/widgets/bg_abang.dart';

import 'register_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  static const Color warnaMerah = Color(0xFF9E182B);

  final ImagePicker picker = ImagePicker();
  final namaController = TextEditingController();
  final telpController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  // Data yang tersimpan
  String namaTampil = '';
  String telpTampil = '';
  String? fotoBase64;

  // Foto yang baru dipilih (belum disimpan)
  String? fotoBaru;

  bool editing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    namaController.dispose();
    telpController.dispose();
    super.dispose();
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  // =========================
  // MUAT PROFIL
  // =========================
  Future<void> loadProfile() async {
    final uid = user?.uid;
    if (uid == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists || !mounted) return;

      final data = doc.data() ?? {};

      // Halaman registrasi menyimpan nomor di field "phone".
      final nama = data['nama']?.toString() ?? '';
      final telp = (data['telp'] ?? data['phone'])?.toString() ?? '';
      final foto = data['photo']?.toString() ?? '';

      setState(() {
        namaTampil = nama;
        telpTampil = telp;
        namaController.text = nama;
        telpController.text = telp;
        fotoBase64 = foto.isEmpty ? null : foto;
      });
    } catch (e) {
      _snack('Gagal memuat profil: $e');
    }
  }

  // =========================
  // PILIH FOTO PROFIL
  // =========================
  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 600,
        maxHeight: 600,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final b64 = base64Encode(bytes);

      if (b64.length > 700 * 1024) {
        _snack('Ukuran foto terlalu besar, pilih foto lain.');
        return;
      }

      if (!mounted) return;
      setState(() {
        fotoBaru = b64;
        editing = true;
      });
    } catch (e) {
      _snack('Gagal memilih foto: $e');
    }
  }

  // =========================
  // SIMPAN PROFIL
  // =========================
  Future<void> saveProfile() async {
    final uid = user?.uid;
    if (uid == null || isLoading) return;

    if (namaController.text.trim().isEmpty) {
      _snack('Nama tidak boleh kosong');
      return;
    }

    setState(() => isLoading = true);

    try {
      final String foto = fotoBaru ?? fotoBase64 ?? '';
      final String nama = namaController.text.trim();
      final String telp = telpController.text.trim();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nama': nama,
        'telp': telp,
        'phone': telp,
        'email': user?.email,
        'photo': foto,
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        namaTampil = nama;
        telpTampil = telp;
        fotoBase64 = foto.isEmpty ? null : foto;
        fotoBaru = null;
        editing = false;
      });

      _snack('Profil berhasil disimpan');
    } catch (e) {
      _snack('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void batalEdit() {
    setState(() {
      namaController.text = namaTampil;
      telpController.text = telpTampil;
      fotoBaru = null;
      editing = false;
    });
  }

  // =========================
  // UBAH KATA SANDI (lewat email)
  // =========================
  Future<void> ubahKataSandi() async {
    final email = user?.email;
    if (email == null || email.isEmpty) {
      _snack('Email tidak ditemukan');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _snack('Tautan ubah kata sandi dikirim ke $email');
    } catch (e) {
      _snack('Gagal mengirim tautan: $e');
    }
  }

  // =========================
  // KELUAR
  // =========================
  Future<void> logout() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar', style: TextStyle(color: warnaMerah)),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AuthPage()),
      (route) => false,
    );
  }

  // =========================
  // TAMPILAN
  // =========================
  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;

    // Header: padding atas (18) + judul (24) + jarak (14) + avatar (90)
    final double topKonten = statusBar + 18 + 24 + 14 + 90 + 8;
    final double tinggiHeader = topKonten + 24;

    final String? uid = user?.uid;

    if (uid == null) {
      return const Center(child: Text('Silakan login terlebih dahulu'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        // KOST MILIK AKUN INI
        stream: FirebaseFirestore.instance
            .collection('kost')
            .where('owner_id', isEqualTo: uid)
            .snapshots(),
        builder: (context, kostSnapshot) {
          final kostDocs = kostSnapshot.data?.docs ?? [];

          return StreamBuilder<QuerySnapshot>(
            // PENGHUNI MILIK AKUN INI (butuh field owner_id di users)
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
                        padding: EdgeInsets.only(top: statusBar),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 24,
                              child: Text(
                                'Profil Pemilik',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildHeaderProfil(),
                          ],
                        ),
                      ),
                    ),

                    // KONTEN
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, topKonten, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatistik(kostDocs.length, totalPenghuni),
                          const SizedBox(height: 14),
                          _buildDataDiri(),
                          const SizedBox(height: 14),
                          _buildKostSaya(kostDocs),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: logout,
                              icon: const Icon(Icons.logout, size: 20),
                              label: const Text('Keluar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: warnaMerah,
                                side: const BorderSide(color: warnaMerah),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
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
      ),
    );
  }

  // ==========================================================
  // AVATAR + NAMA (di header merah)
  // ==========================================================
  Widget _buildHeaderProfil() {
    return Row(
      children: [
        GestureDetector(
          onTap: pickImage,
          child: SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              children: [
                _buildAvatar(),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: warnaMerah,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaTampil.isEmpty ? '-' : namaTampil,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Pemilik Kost',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final Uint8List? bytes = _decode(fotoBaru ?? fotoBase64);

    return CircleAvatar(
      radius: 45,
      backgroundColor: const Color(0xFFE9E4DD),
      backgroundImage: bytes != null ? MemoryImage(bytes) : null,
      child: bytes == null
          ? Icon(Icons.person, size: 64, color: Colors.grey.shade500)
          : null,
    );
  }

  // ==========================================================
  // JUMLAH KOST & PENGHUNI
  // ==========================================================
  Widget _buildStatistik(int totalKost, int totalPenghuni) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _dekorasiKartu(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Jumlah Kost: $totalKost',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            'Jumlah Penghuni: $totalPenghuni',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DATA DIRI
  // ==========================================================
  Widget _buildDataDiri() {
    return Container(
      width: double.infinity,
      decoration: _dekorasiKartu(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul merah
          Container(
            width: double.infinity,
            color: warnaMerah,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: const Text(
              'Data Diri',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: editing ? _buildFormEdit() : _buildInfoDiri(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDiri() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _infoItem('Nama Lengkap', namaTampil)),
            Expanded(child: _infoItem('No.HandPhone', telpTampil)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _infoItem('Email', user?.email ?? '')),
            // Kata sandi tidak bisa dibaca dari Firebase, jadi disamarkan.
            Expanded(child: _infoItem('Kata Sandi', '••••••••')),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () => setState(() => editing = true),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _infoItem(String label, String nilai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          nilai.isEmpty ? '-' : nilai,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildFormEdit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputEdit(namaController, 'Nama Lengkap'),
        const SizedBox(height: 10),
        _inputEdit(
          telpController,
          'No.HandPhone',
          keyboard: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        TextField(
          readOnly: true,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: user?.email ?? '-',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: ubahKataSandi,
          icon: const Icon(Icons.lock_reset, size: 18, color: warnaMerah),
          label: const Text(
            'Ubah kata sandi (kirim tautan ke email)',
            style: TextStyle(fontSize: 12, color: warnaMerah),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : batalEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: warnaMerah,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _inputEdit(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: warnaMerah, width: 1.5),
        ),
      ),
    );
  }

  // ==========================================================
  // KOST SAYA
  // ==========================================================
  Widget _buildKostSaya(List<QueryDocumentSnapshot> kostDocs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _dekorasiKartu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kost Saya',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (kostDocs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Belum ada kost',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            )
          else
            ...kostDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildBarisKost(doc.id, data);
            }),
        ],
      ),
    );
  }

  Widget _buildBarisKost(String kostId, Map<String, dynamic> data) {
    final String nama = data['nama_kos']?.toString() ?? '-';
    final int jumlahKamar = _toInt(data['jumlah_kamar']);
    final Uint8List? foto = _decode(data['foto_kos']?.toString());

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KamarPage(
              kostId: kostId,
              namaKos: nama,
              fotoBase64: data['foto_kos']?.toString(),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: foto == null
                    ? Container(
                        color: const Color(0xFFF4F4F4),
                        child: Icon(
                          Icons.home_work_outlined,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : Image.memory(foto, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.door_front_door_outlined, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$jumlahKamar Kamar',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDDFFDD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 22),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // UTILITAS
  // ==========================================================
  BoxDecoration _dekorasiKartu() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static Uint8List? _decode(String? b64) {
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