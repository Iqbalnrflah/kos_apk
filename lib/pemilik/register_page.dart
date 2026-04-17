import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kospay_dart/pemilik/main_page.dart';
import 'package:kospay_dart/penghuni/home_page_penghuni.dart';

class AuthPage extends StatefulWidget {
  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  String role = "penghuni";

  final email = TextEditingController();
  final password = TextEditingController();
  final nama = TextEditingController();
  final phone = TextEditingController();
  final confirmPassword = TextEditingController();

  /// 🔥 LOGIN FIX
  Future<void> login() async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // 🔥 AMBIL DATA USER
      DocumentSnapshot data = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .get();

      // 🔥 CEK DATA ADA / TIDAK
      if (!data.exists) {
        throw Exception("Data user tidak ditemukan di Firestore");
      }

      Map<String, dynamic> userData =
          data.data() as Map<String, dynamic>;

      String userRole = userData['role'] ?? "penghuni";

      print("ROLE LOGIN: $userRole");

      /// 🔥 PINDAH HALAMAN SESUAI ROLE
      Widget targetPage;

      if (userRole == "pemilik") {
        targetPage = MainPage();
      } else {
        targetPage = HomePenghuni(); // tanpa search ✔️
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => targetPage),
        (route) => false,
      );

    } catch (e) {
      print("ERROR LOGIN: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login gagal")),
      );
    }
  }

  /// 🔥 REGISTER FIX
  Future<void> register() async {
    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password tidak sama")),
      );
      return;
    }

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .set({
        'email': email.text.trim(),
        'role': role,
        'nama': nama.text,
        'phone': phone.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register berhasil")),
      );

      setState(() {
        isLogin = true;
      });

    } catch (e) {
      print("ERROR REGISTER: $e");

      String message = "Register gagal";

      if (e.toString().contains('email-already-in-use')) {
        message = "Email sudah terdaftar, silakan login";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),

            /// SWITCH LOGIN / REGISTER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => isLogin = true),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: isLogin ? Colors.white : Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () => setState(() => isLogin = false),
                  child: Text(
                    "Registrasi",
                    style: TextStyle(
                      color: !isLogin ? Colors.white : Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            /// FORM
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [

                    /// ROLE SWITCH
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _roleButton("penghuni"),
                        SizedBox(width: 10),
                        _roleButton("pemilik"),
                      ],
                    ),

                    SizedBox(height: 20),

                    if (!isLogin)
                      TextField(
                        controller: nama,
                        decoration:
                            InputDecoration(labelText: "Nama Lengkap"),
                      ),

                    if (!isLogin)
                      TextField(
                        controller: phone,
                        decoration:
                            InputDecoration(labelText: "Nomor HP"),
                      ),

                    TextField(
                      controller: email,
                      decoration: InputDecoration(labelText: "Email"),
                    ),

                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Password"),
                    ),

                    if (!isLogin)
                      TextField(
                        controller: confirmPassword,
                        obscureText: true,
                        decoration:
                            InputDecoration(labelText: "Konfirmasi Password"),
                      ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        if (isLogin) {
                          login();
                        } else {
                          register();
                        }
                      },
                      child: Text(isLogin ? "Masuk" : "Daftar"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ROLE BUTTON
  Widget _roleButton(String value) {
    bool selected = role == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          role = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value.toUpperCase(),
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}