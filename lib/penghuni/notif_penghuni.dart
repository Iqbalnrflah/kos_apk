import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'propil_penghuni.dart';
import '../widgets/header.dart';

class NotifPenghuniPage extends StatelessWidget {
  const NotifPenghuniPage({super.key});
  Widget buildProfileIcon(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const CircleAvatar(
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
          return const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          );
        }
        var data = snapshot.data!.data()as Map<String, dynamic>?;
        String? photo = data?['photo'];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditProfilPenghuniPage(),
              ),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor:
                const Color(0xFF9E182B),
            backgroundImage:
              (photo != null && photo.isNotEmpty)
                ? MemoryImage(base64Decode(photo),)
                : null,
            child:
              (photo == null || photo.isEmpty)
                ? const Icon(Icons.person,color: Colors.white,)
                : null,
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomHeader(title: "Notifikasi"),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pembayaran')
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:CircularProgressIndicator());
                }
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Belum ada notifikasi",),
                  );
                }
                var data = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.only(top: 0),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var item = data[index].data() as Map<String, dynamic>;
                    String nama = item['penghuni_nama'] ?? "-";
                    String metode =item['metode'] ?? "-";
                    int jumlah = item['jumlah_bayar'] ?? 0;
                    Timestamp? waktu = item['tanggal_bayar'];
                    DateTime date = waktu != null
                            ? waktu.toDate()
                            : DateTime.now();
                    String tanggal =
                        "${date.day.toString().padLeft(2, '0')}/"
                        "${date.month.toString().padLeft(2, '0')}/"
                        "${date.year} • "
                        "${date.hour.toString().padLeft(2, '0')}:"
                        "${date.minute.toString().padLeft(2, '0')}";
                    return Container(
                      margin:
                          EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: index == 0 ? 4 : 0,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      decoration:
                          const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black26,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Text(
                                  "Konfirmasi Pembayaran Berhasil",
                                  style: TextStyle(
                                    fontWeight:
                                      FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                tanggal,
                                style:
                                    const TextStyle(
                                  color:Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            nama,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                metode,
                                style:
                                    const TextStyle(
                                      color:
                                      Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Rp.$jumlah",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 16,
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