import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openMap(BuildContext context, String alamat) async {
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': alamat,
  });

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tidak bisa membuka Maps")),
    );
  }
}