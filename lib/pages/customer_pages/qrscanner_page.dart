// qrscanner_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerWidget extends StatefulWidget {
  final VoidCallback? onScannerToggle;
  final bool isScannerActive;

  const QRScannerWidget({
    super.key, 
    required this.isScannerActive,
    this.onScannerToggle,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted && widget.onScannerToggle != null) {
      widget.onScannerToggle!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isScannerActive
        ? MobileScanner(
            controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              final Uint8List? image = capture.image;

              // Debugging barcode detection
              for (final barcode in barcodes) {
                debugPrint('Barcode found: ${barcode.rawValue}');
              }

              // Check if image is available and show dialog after frame
              if (image != null) {
                // Ensure dialog is shown after the current frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          barcodes.isNotEmpty
                              ? barcodes.first.rawValue ?? "No Data"
                              : "No Barcode Found",
                        ),
                        content: Image(
                          image: MemoryImage(image),
                        ),
                      );
                    },
                  );
                });
              }
            },
          )
        : const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Press the button to start scanning'),
              ],
            ),
          );
  }
}