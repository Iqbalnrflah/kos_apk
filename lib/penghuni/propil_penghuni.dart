import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kospay_dart/pemilik/register_page.dart';

class EditProfilPenghuniPage extends StatefulWidget {
  const EditProfilPenghuniPage({super.key});

  @override
  State<EditProfilPenghuniPage> createState() =>
      _EditProfilPenghuniPageState();
}
class _EditProfilPenghuniPageState
    extends State<EditProfilPenghuniPage> {
    File? _image;
    String? imageBase64;
    String? imageUrl;
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
      print("ERROR LOAD PROFILE: $e");
    }
  }
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String base64 =
          base64Encode(imageFile.readAsBytesSync());
      setState(() {
        _image = imageFile;
        imageBase64 = base64;
      });
    }
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);
    try {
      String? photoData = imageBase64;
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
        const SnackBar(
          content: Text("Profil berhasil disimpan"),
        ),
      );
    } catch (e) {
      print("ERROR SAVE: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal simpan profil"),
        ),
      );
    }
    setState(() => isLoading = false);
  }
  Future<void> handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => AuthPage(),
      ),
      (route) => false,
    );
  }
  Widget buildProfileImage() {
    if (_image != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_image!),
      );
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundImage:
            MemoryImage(base64Decode(imageUrl!)),
      );
    }
    return const CircleAvatar(
      radius: 60,
      child: Icon(
        Icons.camera_alt,
        size: 40,
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboard =
        TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: handleLogout,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickImage,
                child: buildProfileImage(),
              ),
              const SizedBox(height: 15),
              const Text(
                "Tekan foto untuk mengganti",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              buildTextField(
                label: "Nama",
                controller: namaController,
              ),
              const SizedBox(height: 15),
              buildTextField(
                label: "No Telp",
                controller: telpController,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              buildTextField(
                label: "Email",
                controller: TextEditingController(
                  text: user?.email ?? "",
                ),
                readOnly: true,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9E182B),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      isLoading ? null : saveProfile,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Simpan Profil",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}