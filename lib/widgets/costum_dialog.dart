import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
}) async {
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
              icon,
              color: color,
              size: 70,
            ),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              subtitle,
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