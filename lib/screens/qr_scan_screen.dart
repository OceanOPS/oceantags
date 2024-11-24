import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue; // Adjust to use `rawValue`
            if (code != null) {
              // Display or use the scanned code
              print('Scanned Code: $code');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Scanned: $code')),
              );
            }
          }
        },
      ),
    );
  }
}
