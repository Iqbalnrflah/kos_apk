import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'kamar_penghuni.dart';
import 'propil_penghuni.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String search = "";

  /// 🔥 PROFILE ICON FIREBASE (BALIKIN)
  Widget buildProfileIcon() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return CircleAvatar(
        radius: 18,
        child: Icon(Icons.person),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>?;
        String? photo = data?['photo'];

        if (photo != null && photo.isNotEmpty) {
          return CircleAvatar(
            radius: 18,
            backgroundImage: MemoryImage(base64Decode(photo)),
          );
        }

        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.red.shade800,
          child: Icon(Icons.person, color: Colors.white),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          /// 🔥 HEADER + PROFILE (BALIK)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilPenghuniPage(),
                      ),
                    );
                  },
                  child: buildProfileIcon(),
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH
          Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          search = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Cari kost disini",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.red),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kost')
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Belum ada data"));
                }

                var data = snapshot.data!.docs;

                /// 🔥 FILTER
                var filteredData = data.where((doc) {
                  var item = doc.data() as Map<String, dynamic>;

                  String namaKos =
                      (item['nama_kos'] ?? "")
                          .toString()
                          .toLowerCase();

                  return namaKos.contains(search);
                }).toList();

                if (filteredData.isEmpty) {
                  return Center(child: Text("Tidak ditemukan"));
                }

                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {

                    var item =
                        filteredData[index].data()
                            as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KamarPage(
                              kosId: filteredData[index].id,
                            ),
                          ),
                        );
                      },

                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade800,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama_kos'] ?? "Tanpa Nama",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              item['pemilik'] ?? "Tanpa Pemilik",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              item['alamat'] ?? "-",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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