import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'detail_tagihan.dart';
import 'propil_penghuni.dart';

class TagihanPenghuniPage extends StatelessWidget {

  /// 🔥 PROFILE ICON
  Widget buildProfileIcon(BuildContext context) {
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

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfilPenghuniPage(),
              ),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.red,
            backgroundImage: (photo != null && photo.isNotEmpty)
                ? MemoryImage(base64Decode(photo))
                : null,
            child: (photo == null || photo.isEmpty)
                ? Icon(Icons.person, color: Colors.white)
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User belum login")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          /// 🔥 HEADER FULL
          Container(
            width: double.infinity,
            color: Colors.red.shade800,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 12,
              right: 12,
              bottom: 20,
            ),
            child: Column(
              children: [

                /// 🔹 PROFILE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                    buildProfileIcon(context),
                  ],
                ),

                SizedBox(height: 10),

                /// 🔹 TITLE
                Text(
                  "Tagihan Bulanan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 LIST TAGIHAN (FIX ERROR DI SINI)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('kamar')
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                /// ✅ FIX UTAMA: FILTER DI APP (NO INDEX ERROR)
                var data = snapshot.data!.docs.where((doc) {
                  var item = doc.data() as Map<String, dynamic>;
                  return item['penghuniId'] == uid;
                }).toList();

                if (data.isEmpty) {
                  return Center(child: Text("Belum ada tagihan"));
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {

                    var doc = data[index];
                    var item = doc.data() as Map<String, dynamic>;

                    String nama = item['penghuni_nama'] ?? "-";

                    /// 🔥 HANDLE TANGGAL AMAN
                    DateTime tglMasuk;
                    var raw = item['tanggal_masuk'];

                    if (raw is Timestamp) {
                      tglMasuk = raw.toDate();
                    } else {
                      tglMasuk = DateTime.now();
                    }

                    bool jatuhTempo = DateTime.now().day >= tglMasuk.day;
                    String status = jatuhTempo ? "Jatuh Tempo" : "Mendatang";

                    /// 🔥 BULAN DEPAN (TANPA TAHUN)
                    DateTime tagihanDate = DateTime(
                      tglMasuk.month == 12
                          ? tglMasuk.year + 1
                          : tglMasuk.year,
                      tglMasuk.month == 12
                          ? 1
                          : tglMasuk.month + 1,
                      tglMasuk.day,
                    );

                    String bulan =
                        "${tagihanDate.day.toString().padLeft(2, '0')}/${tagihanDate.month.toString().padLeft(2, '0')}";

                    String kamarId = doc.id;
                    String kosId = doc.reference.parent.parent?.id ?? "";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailTagihanPage(
                              data: item,
                              kosId: kosId,
                              kamarId: kamarId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade800,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  status,
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bulan,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )

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