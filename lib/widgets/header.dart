import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../penghuni/propil_penghuni.dart';

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [

        /// ATAS PUTIH
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 65,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          color: Colors.white,

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.end,

            children: [

              if (user == null)
                const CircleAvatar(
                  radius: 18,
                  child: Icon(Icons.person),
                )

              else
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const CircleAvatar(
                        radius: 18,
                        child: Icon(Icons.person),
                      );
                    }

                    var data =
                        snapshot.data!.data()
                            as Map<String, dynamic>?;

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
                            (photo != null &&
                                    photo.isNotEmpty)
                                ? MemoryImage(
                                    base64Decode(photo),
                                  )
                                : null,

                        child:
                            (photo == null ||
                                    photo.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  )
                                : null,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        /// TITLE MERAH
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),

          color: const Color(0xFF9E182B),

          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}