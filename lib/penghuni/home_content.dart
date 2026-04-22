import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Home Penghuni",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  search = val.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Cari kost...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kost')
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
                  return (item['nama_kos'] ?? "")
                      .toString()
                      .toLowerCase()
                      .contains(search);
                }).toList();

                if (data.isEmpty) {
                  return Center(child: Text("Tidak ditemukan"));
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {

                    var item = data[index].data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade800,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama_kos'] ?? "-",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            item['alamat'] ?? "-",
                            style: TextStyle(color: Colors.white70),
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