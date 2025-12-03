// lib/widgets/qr_scanner_dialog.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerDialog extends StatefulWidget {
  final Function(String) onQRCodeScanned;
  final String title;
  final String subtitle;
  final bool allowManualInput;

  const QRScannerDialog({
    Key? key,
    required this.onQRCodeScanned,
    required this.title,
    required this.subtitle,
    this.allowManualInput = false,
  }) : super(key: key);

  @override
  State<QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<QRScannerDialog> {
  late MobileScannerController _controller;
  final TextEditingController _manualInputController = TextEditingController();
  bool _isTorchOn = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      torchEnabled: _isTorchOn,
      facing: _cameraFacing,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _handleManualSubmit() {
    if (_manualInputController.text.isNotEmpty) {
      widget.onQRCodeScanned(_manualInputController.text);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
      _controller.toggleTorch();
    });
  }

  void _switchCamera() {
    setState(() {
      _cameraFacing = _cameraFacing == CameraFacing.back 
          ? CameraFacing.front 
          : CameraFacing.back;
      _controller.switchCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.subtitle,textAlign: TextAlign.center,),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String? code = barcodes.first.rawValue;
                          if (code != null) {
                            widget.onQRCodeScanned(code);
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        }
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.black.withOpacity(0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isTorchOn 
                                    ? Icons.flash_on 
                                    : Icons.flash_off,
                                color: Colors.white,
                              ),
                              onPressed: _toggleTorch,
                            ),
                            IconButton(
                              icon: Icon(
                                _cameraFacing == CameraFacing.front
                                    ? Icons.camera_front
                                    : Icons.camera_rear,
                                color: Colors.white,
                              ),
                              onPressed: _switchCamera,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.allowManualInput) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _manualInputController,
                decoration: InputDecoration(
                  labelText: 'Or enter code manually',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check_circle),
                    onPressed: _handleManualSubmit,
                  ),
                ),
                onSubmitted: (_) => _handleManualSubmit(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}