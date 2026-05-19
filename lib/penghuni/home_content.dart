import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kamar_penghuni.dart';
import '../widgets/header.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String search = "";
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          CustomHeader(title: "Beranda"),
          Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF9E182B)),
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
                  Icon(Icons.search, color: Color(0xFF9E182B)),
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        margin: EdgeInsets.only(
                          bottom: 0,
                        ),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color (0xFF9E182B),
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
      );
  }
}