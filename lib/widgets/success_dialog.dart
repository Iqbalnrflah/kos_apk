import 'package:flutter/material.dart';

Future<void> showSuccessDialog(
  BuildContext context,
) async {

  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 70,
            ),

            SizedBox(height: 16),

            Text(
              "Pembayaran Berhasil",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Tagihan anda sudah lunas",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );

  await Future.delayed(
    Duration(seconds: 2),
  );

  Navigator.pop(context);
}