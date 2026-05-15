import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kospay_dart/pemilik/main_page.dart';
import 'package:kospay_dart/penghuni/home_page_penghuni.dart';
import '../widgets/costum_dialog.dart';

class AuthPage extends StatefulWidget {
  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  String role = "penghuni";

  final email = TextEditingController();
  final password = TextEditingController();
  final nama = TextEditingController();
  final phone = TextEditingController();
  final confirmPassword = TextEditingController();
  Future<void> login() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      DocumentSnapshot data = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .get();
      if (!data.exists) {
        throw Exception("Data user tidak ditemukan di Firestore");
      }
      Map<String, dynamic> userData =
          data.data() as Map<String, dynamic>;
      String userRole = userData['role'] ?? "penghuni";
      print("ROLE LOGIN: $userRole");
      Widget targetPage;

      if (userRole == "pemilik") {
        targetPage = MainPage();
      } else {
        targetPage = HomePenghuni();
      }
      await showCustomDialog(
        context: context,
        icon: Icons.check_circle,
        color: Colors.green,
        title: "Login Berhasil",
        subtitle: "Selamat datang kembali",
      );
      setState(() {
        isLoading = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => targetPage),
        (route) => false,
      );

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("ERROR LOGIN: $e");
      await showCustomDialog(
        context: context,
        icon: Icons.error,
        color: Colors.red,
        title: "Login Gagal",
        subtitle: "Email atau password salah");
    }
  }
  Future<void> register() async {
    if (password.text != confirmPassword.text) {
      await showCustomDialog(
        context: context,
        icon: Icons.error,
        color: Colors.orange,
        title: "Password Tidak Cocok",
        subtitle: "Password dan konfirmasi password tidak cocok");
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

      await showCustomDialog(
        context: context,
        icon: Icons.check_circle,
        color: Colors.green,
        title: "Registrasi Berhasil",
        subtitle: "Silakan login dengan akun Anda");
      setState(() {
        isLogin = true;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("ERROR REGISTER: $e");
      String message = "Register gagal";
      if (e.toString().contains('email-already-in-use')) {
        message = "Email sudah terdaftar, silakan login";
      }
      await showCustomDialog(
        context: context,
        icon: Icons.error,
        color: Colors.red,
        title: "Registrasi Gagal",
        subtitle: message);
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
          SizedBox(height: 50),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => isLogin = true),
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: isLogin ? Colors.black : Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(width: 30),

              GestureDetector(
                onTap: () => setState(() => isLogin = false),
                child: Text(
                  "Registrasi",
                  style: TextStyle(
                    color: !isLogin ? Colors.black : Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          /// BIAR FORM NEMPEL BAWAH
          Expanded(
            child: Container(),
          ),

          /// FORM LOGIN / REGISTER
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,

            height: isLogin ? 360 : 520,
            width: double.infinity,

            padding: EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),

            child: SingleChildScrollView(
              child: Column(
                children: [

                  /// ROLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roleButton("penghuni"),
                      SizedBox(width: 10),
                      _roleButton("pemilik"),
                    ],
                  ),

                  SizedBox(height: 25),

                  /// REGISTER ONLY
                  if (!isLogin)
                    TextField(
                      controller: nama,
                      decoration: InputDecoration(
                        labelText: "Nama Lengkap",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  if (!isLogin)
                    SizedBox(height: 15),

                  if (!isLogin)
                    TextField(
                      controller: phone,
                      decoration: InputDecoration(
                        labelText: "Nomor HP",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  if (!isLogin)
                    SizedBox(height: 15),

                  /// EMAIL
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  /// PASSWORD
                  TextField(
                    controller: password,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),

                  /// KONFIRMASI PASSWORD
                  if (!isLogin)
                    SizedBox(height: 15),

                  if (!isLogin)
                    TextField(
                      controller: confirmPassword,
                      obscureText: !showConfirmPassword,
                      decoration: InputDecoration(
                        labelText: "Konfirmasi Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),

                  SizedBox(height: 30),

                  /// BUTTON
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9E182B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isLoading
                      ? null
                      :() {
                        if (isLogin) {
                          login();
                        } else {
                          register();
                        }
                      },
                      child: isLoading
                      ?SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      :Text(
                        isLogin ? "Login" : "Register",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ]
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
          color: selected ? Color(0xFF9E182B) : Colors.grey[300],
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