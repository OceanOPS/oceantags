import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:oceantags/database/db.dart';
import 'platform_detail_screen.dart';

class QRScanScreen extends StatelessWidget {
  final AppDatabase database;

  const QRScanScreen({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  final String? reference = _extractReference(code);
                  if (reference != null) {
                    await _searchAndNavigate(reference, context);
                  } else {
                    _showMessage(context, "Invalid QR Code");
                  }
                }
              }
            },
          ),

          // ✅ Blurred overlay with transparent scan area
          Positioned.fill(
            child: CustomPaint(
              painter: QRScannerOverlay(),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Extracts reference from URL (e.g., `https://www.ocean-ops.org/oceantags/RFHCZ3S` → `RFHCZ3S`)
  String? _extractReference(String url) {
    const String prefix = "https://www.ocean-ops.org/oceantags/";
    if (url.startsWith(prefix)) {
      return url.substring(prefix.length);
    }
    return null; // Not a valid OceanTags QR code
  }

  /// ✅ Searches database for platform & navigates if found
  Future<void> _searchAndNavigate(String reference, BuildContext context) async {
    final platform = await database.getPlatformByReference(reference); // ✅ Search database
    if (platform != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlatformDetailScreen(platform: platform)),
      );
    } else {
      _showMessage(context, "Platform not found");
    }
  }

  /// ✅ Displays a message using Snackbar
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// ✅ Custom painter to draw a blurred background with a transparent scanning square
class QRScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.7);
    final cutoutSize = size.width * 0.6; // Square size is 60% of screen width
    final cutoutOffset = Offset(
      (size.width - cutoutSize) / 2, // Center horizontally
      (size.height - cutoutSize) / 3, // Position slightly above center
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)) // Full screen
      ..addRect(Rect.fromLTWH(cutoutOffset.dx, cutoutOffset.dy, cutoutSize, cutoutSize)); // Clear square
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // ✅ Draw white border around scanning area
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(
      Rect.fromLTWH(cutoutOffset.dx, cutoutOffset.dy, cutoutSize, cutoutSize),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(QRScannerOverlay oldDelegate) => false;
}
