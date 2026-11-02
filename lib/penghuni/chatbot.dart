import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotWidget extends StatefulWidget {
  final VoidCallback onClose;

  const ChatbotWidget({
    super.key,
    required this.onClose,
  });

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController controller = TextEditingController();

  String namaUser = "pengguna";
  String noKamar = "-";
  int hargaKamar = 0;

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  } 
  

  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print("USER LOGIN = ${user?.uid}");
      if(user == null) return;
      String pesanPembuka = "";
      final kamarSnapshot = await FirebaseFirestore.instance
          .collection('kamar')
          .where('penghuniId', isEqualTo: user.uid)
          .get();
        print("JUMLAH DATA = ${kamarSnapshot.docs.length}");
      if (kamarSnapshot.docs.isNotEmpty) {
        final kamar =
            kamarSnapshot.docs.first.data();

        namaUser = kamar['penghuni_nama'] ?? "pengguna". toString();
        noKamar = kamar['No_Kamar'] ?? "-".toString();
        hargaKamar = (kamar['harga'] ?? 0 as num ).toint();

        pesanPembuka = 
            "Halo $namaUser 👋\n\n"
            "🏠 Selamat datang di KostPay\n\n"
            "🚪 Kamar : $noKamar\n"
            "💰 Tagihan : Rp$hargaKamar / bulan\n\n"
            "⚠️ Jangan lupa melakukan pembayaran sebelum jatuh tempo.\n\n"
            "Ada yang bisa saya bantu?";
      } else {
        pesanPembuka =
            "Halo $namaUser 👋\n\n"
            "Anda belum terdaftar pada kamar kos.\n\n"
            "Ada yang bisa saya bantu?";
      }
      if (!mounted) return;
      setState(() {
        messages = [
          {
            "text": pesanPembuka,
            "isUser": false,
          }
        ];
      });
    } catch (e) {
      setState(() {
        messages = [
          {
            "text":
                "Halo 👋\n\nTerjadi kesalahan saat mengambil data.",
            "isUser": false,
          }
        ];
      });
    }
  }

  void sendMessage() {
    if (controller.text.trim().isEmpty) return;

    String text = controller.text;

    setState(() {
      messages.add({
        "text": text,
        "isUser": true,
      });
    });

    controller.clear();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      String reply = getBotReply(text);
      @override
      void dispose() {
        controller.dispose();
        super.dispose();
      }
      setState(() {
        messages.add({
          "text": reply,
          "isUser": false,
        });
      });
    });
  }

  String getBotReply(String text) {
    text = text.toLowerCase();

    if (text.contains("tagihan")) {
      return "Tagihan kamar Anda sebesar Rp$hargaKamar per bulan.";
    }

    if (text.contains("bayar")) {
      return "Untuk melakukan pembayaran silakan buka menu Tagihan lalu tekan tombol Bayar.";
    }

    if (text.contains("kamar")) {
      return "Anda saat ini menempati $noKamar.";
    }

    if (text.contains("lokasi")) {
      return "Silakan lihat alamat kos pada halaman Home.";
    }

    if (text.contains("panduan")) {
      return "Gunakan menu Home, Tagihan, Daftar dan Notif sesuai kebutuhan.";
    }

    return "Maaf, saya belum memahami pertanyaan tersebut.";
  }

  void quickMessage(String text) {
    controller.text = text;
    sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF9E182B),
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "KostPay Assistant",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text("Tagihan"),
                  onPressed: () => quickMessage("tagihan"),
                ),
                ActionChip(
                  label: const Text("Kamar"),
                  onPressed: () => quickMessage("kamar"),
                ),
                ActionChip(
                  label: const Text("Panduan"),
                  onPressed: () => quickMessage("panduan"),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUser = messages[index]["isUser"];

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(
                        maxWidth: 260,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF9E182B)
                            : Colors.grey.shade200,
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: Text(
                        messages[index]["text"],
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  backgroundColor:
                      const Color(0xFF9E182B),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}