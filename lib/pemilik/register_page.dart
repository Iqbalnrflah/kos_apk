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
        throw Exception("Data user tidak ditemukan");
      }
      Map<String, dynamic> userData =
          data.data() as Map<String, dynamic>;
      String userRole = userData['role'] ?? "penghuni";
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
      await showCustomDialog(
        context: context,
        icon: Icons.error,
        color: Colors.red,
        title: "Login Gagal",
        subtitle: "Email atau password salah",
      );
    }
  }

  Future<void> register() async {
    if (password.text != confirmPassword.text) {
      await showCustomDialog(
        context: context,
        icon: Icons.error,
        color: Colors.orange,
        title: "Password Tidak Cocok",
        subtitle: "Password dan konfirmasi password tidak cocok",
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
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
      setState(() {
        isLoading = false;
      });
      await showCustomDialog(
        context: context,
        icon: Icons.check_circle,
        color: Colors.green,
        title: "Registrasi Berhasil",
        subtitle: "Silakan login dengan akun Anda",
      );
      setState(() {
        isLogin = true;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      String message = "Register gagal";
      if (e.toString().contains('email-already-in-use')) {
        message = "Email sudah terdaftar";
      }
      await showCustomDialog(
        context: context,
        icon: Icons.error,
        color: Colors.red,
        title: "Registrasi Gagal",
        subtitle: message,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(
              child: Image.asset(
                "assets/img/LogoPay.png",
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            )),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isLogin ? 430 : 620,
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
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLogin = true;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                "Login",
                                style: TextStyle(
                                  color: isLogin
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              AnimatedContainer(
                                duration:
                                    Duration(milliseconds: 300),
                                width: isLogin ? 60 : 0,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Color(0xFF9E182B),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 40),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLogin = false;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                "Registrasi",
                                style: TextStyle(
                                  color: !isLogin
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              AnimatedContainer(
                                duration:
                                    Duration(milliseconds: 300),
                                width: !isLogin ? 90 : 0,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Color(0xFF9E182B),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        _roleButton("penghuni"),
                        SizedBox(width: 10),
                        _roleButton("pemilik"),
                      ],
                    ),
                    SizedBox(height: 25),
                    if (!isLogin)
                      TextField(
                        controller: nama,
                        decoration: InputDecoration(
                          labelText: "Nama Lengkap",
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
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
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    if (!isLogin)
                      SizedBox(height: 15),
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: password,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword =
                                  !showPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    if (!isLogin)
                      SizedBox(height: 15),
                    if (!isLogin)
                      TextField(
                        controller: confirmPassword,
                        obscureText:
                            !showConfirmPassword,
                        decoration: InputDecoration(
                          labelText:
                              "Konfirmasi Password",
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showConfirmPassword =
                                    !showConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    SizedBox(height: 35),
                    SizedBox(
                      width: 220,
                      height: 55,
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Color(0xFF9E182B),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (isLogin) {
                                  login();
                                } else {
                                  register();
                                }
                              },
                        child: isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isLogin
                                    ? "Login"
                                    : "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
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

  Widget _roleButton(String value) {
    bool selected = role == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          role = value;
        });
      },

      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Color(0xFF9E182B)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          value.toUpperCase(),
          style: TextStyle(
            color:
                selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}