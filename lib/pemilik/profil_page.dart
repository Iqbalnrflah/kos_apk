import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_page.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  File? _image;
  String? imageBase64; // 🔥 data baru
  String? imageUrl;    // 🔥 data dari Firestore
  bool isLoading = false;

  final picker = ImagePicker();
  final namaController = TextEditingController();
  final telpController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // 🔥 LOAD DATA
  Future<void> loadProfile() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        var data = doc.data();

        setState(() {
          namaController.text = data?['nama'] ?? '';
          telpController.text = data?['telp'] ?? '';
          imageUrl = data?['photo'] ?? '';
        });
      }
    } catch (e) {
      print("Load error: $e");
    }
  }

  // 📸 PILIH GAMBAR + COMPRESS
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40, // 🔥 makin kecil makin ringan
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      String base64 = base64Encode(imageFile.readAsBytesSync());

      setState(() {
        _image = imageFile;
        imageBase64 = base64;
      });
    }
  }

  // 💾 SIMPAN TANPA STORAGE
  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    try {
      String? photoData = imageBase64;

      // kalau tidak pilih gambar baru → pakai lama
      if (photoData == null || photoData.isEmpty) {
        photoData = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'nama': namaController.text,
        'telp': telpController.text,
        'email': user!.email,
        'photo': photoData ?? '',
      }, SetOptions(merge: true));

      setState(() {
        imageUrl = photoData;
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil berhasil disimpan")),
      );

    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal simpan")),
      );
    }

    setState(() => isLoading = false);
  }

  // 🖼️ TAMPILKAN FOTO
  Widget buildProfileImage() {
    if (_image != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_image!),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(base64Decode(imageUrl!)),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        child: Icon(Icons.camera_alt, size: 40),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AuthPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),

            GestureDetector(
              onTap: pickImage,
              child: buildProfileImage(),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 15),

                  TextField(
                    controller: telpController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "No Telp",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 15),

                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      hintText: user?.email ?? "-",
                    ),
                  ),

                  SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: isLoading ? null : saveProfile,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Simpan"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}