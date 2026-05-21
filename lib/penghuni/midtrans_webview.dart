import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebView extends StatefulWidget {
  final String url;

  const MidtransWebView({
    super.key,
    required this.url,
  });
  @override
  State<MidtransWebView> createState() => _MidtransWebViewState();
}
class _MidtransWebViewState extends State<MidtransWebView> {
  late final WebViewController controller;
  bool sudahClose = false;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("URL: $url");
            if (!sudahClose &&
                (
                  url.contains("finish") ||
                  url.contains("success") ||
                  url.contains("settlement") ||
                  url.contains("capture") ||
                  url.contains("status_code=200")
                )) {
              sudahClose = true;
              Future.delayed(
                const Duration(seconds: 1),
                () {
                  Navigator.pop(context, true);
                },
              );
            }
            if (!sudahClose &&
                (
                  url.contains("cancel") ||
                  url.contains("deny") ||
                  url.contains("expire")
                )) {
              sudahClose = true;
              Navigator.pop(context, false);
            }
          },
          onNavigationRequest: (request) {
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
      ),
      body: WebViewWidget(
        controller: controller,
      ),
      
    );
  }
}