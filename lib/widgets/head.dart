import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../penghuni/propil_penghuni.dart';

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}