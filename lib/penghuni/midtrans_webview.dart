import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebView extends StatefulWidget {
  final String url;

  const MidtransWebView({super.key, required this.url});

  @override
  State<MidtransWebView> createState() => _MidtransWebViewState();
}

class _MidtransWebViewState extends State<MidtransWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
  print("URL: ${request.url}");

  // 🔥 DETEKSI BALIK DARI MIDTRANS
  if (request.url.contains("myapp://success")) {
    Navigator.pop(context, true);
    return NavigationDecision.prevent;
  }

  // fallback safety
  if (request.url.contains("finish")) {
    Navigator.pop(context, true);
    return NavigationDecision.prevent;
  }

  return NavigationDecision.navigate;
},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
        backgroundColor: Colors.red,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}