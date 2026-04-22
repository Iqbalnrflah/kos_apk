import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'detail_tagihan.dart';
import 'propil_penghuni.dart';

class TagihanPenghuniPage extends StatelessWidget {

  /// 🔥 PROFILE ICON (SAMA KAYAK HOME)
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
          backgroundColor: Colors.red,
          child: Icon(Icons.person, color: Colors.white),
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

      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          builder: (_) => EditProfilPenghuniPage(), // 🔥 arahkan ke halaman profil
                        ),
                      );
                    },
                    child: buildProfileIcon(),
                  ),
                ],
              ),
            ),

            /// 🔥 BOX "TAGIHAN BULANAN"
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              color: Colors.red.shade800, // 🔥 pakai color langsung (lebih aman)
              child: Center(
                child: Text(
                  "Tagihan Bulanan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // 🔥 BESAR
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            /// 🔥 LIST TAGIHAN
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

                      var item = data[index].data() as Map<String, dynamic>;

                      String nama = item['penghuni_nama'] ?? "-";

                      /// 🔥 HANDLE TANGGAL
                      DateTime tglMasuk;
                      var raw = item['tanggal_masuk'];

                      if (raw is Timestamp) {
                        tglMasuk = raw.toDate();
                      } else {
                        tglMasuk = DateTime.now();
                      }

                      bool jatuhTempo = DateTime.now().day >= tglMasuk.day;
                      String status = jatuhTempo ? "Jatuh Tempo" : "Mendatang";

                      /// 🔥 BULAN TAGIHAN (BULAN DEPAN)
                      DateTime tagihanDate = DateTime(
                        tglMasuk.month == 12 ? tglMasuk.year + 1 : tglMasuk.year,
                        tglMasuk.month == 12 ? 1 : tglMasuk.month + 1,
                        tglMasuk.day,
                      );

                      String bulan =
                          "${tagihanDate.day.toString().padLeft(2, '0')}/${tagihanDate.month.toString().padLeft(2, '0')}";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailTagihanPage(data: item),
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
      ),
    );
  }
}