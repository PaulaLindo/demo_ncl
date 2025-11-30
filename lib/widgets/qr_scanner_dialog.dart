// lib/widgets/qr_scanner_dialog.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/timekeeping_provider.dart';
import '../theme/app_theme.dart';
import '../utils/color_utils.dart';

class QRScannerDialog extends StatefulWidget {
  const QRScannerDialog({
    super.key,
    this.title = 'Scan QR Code',
    this.subtitle = 'Position the QR code within the frame',
    this.onScanned,
    this.allowManualInput = false,
  });

  final String title;
  final String subtitle;
  final Function(String)? onScanned;
  final bool allowManualInput;

  @override
  State<QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<QRScannerDialog> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  String? _scannedValue;
  bool _showManualInput = false;
  final TextEditingController _manualController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      _isProcessing = true;
      _scannedValue = barcode.rawValue!;
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
      // Stop scanning
      _controller.stop();
      
      // Process the scanned value
      _processScannedValue(_scannedValue!);
    }
  }

  void _processScannedValue(String value) {
    if (widget.onScanned != null) {
      widget.onScanned!(value);
      Navigator.of(context).pop(value);
    } else {
      setState(() {
        _scannedValue = value;
      });
    }
  }

  void _submitManualInput() {
    final value = _manualController.text.trim();
    if (value.isNotEmpty) {
      _processScannedValue(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.subtitle.isNotEmpty)
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.allowManualInput)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showManualInput = !_showManualInput;
                            if (_showManualInput) {
                              _controller.stop();
                            } else {
                              _controller.start();
                            }
                          });
                        },
                        child: Text(
                          _showManualInput ? 'Scan' : 'Manual',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Scanner or Manual Input
              Expanded(
                child: _showManualInput ? _buildManualInput() : _buildScanner(),
              ),
              
              // Footer with scanned result
              if (_scannedValue != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.greenStatus),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Scanned: $_scannedValue',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _scannedValue = null;
                            _isProcessing = false;
                            _controller.start();
                          });
                        },
                        child: const Text('Scan Again'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onBarcodeDetect,
        ),
        
        // Overlay with scan frame
        CustomPaint(
          size: Size.infinite,
          painter: QRScannerOverlayPainter(),
        ),
        
        // Scanning animation
        if (!_isProcessing)
          const Positioned(
            top: 150,
            left: 50,
            right: 50,
            child: ScanningLineAnimation(),
          ),
      ],
    );
  }

  Widget _buildManualInput() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Code Manually',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the QR code value or job ID manually',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _manualController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Code / Job ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryPurple),
              ),
            ),
            onSubmitted: (_) => _submitManualInput(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitManualInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppTheme.primaryPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final scanRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 250,
        height: 250,
      ),
      const Radius.circular(12),
    );

    // Draw overlay
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw scan frame
    canvas.drawRRect(scanRect, strokePaint);

    // Draw corner accents
    final cornerPaint = Paint()
      ..color = AppTheme.primaryPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final cornerLength = 30.0;
    final cornerOffset = 15.0;

    // Top-left corner
    canvas.drawLine(
      Offset(scanRect.left + cornerOffset, scanRect.top + cornerLength),
      Offset(scanRect.left + cornerOffset, scanRect.top + cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left + cornerOffset, scanRect.top + cornerOffset),
      Offset(scanRect.left + cornerLength, scanRect.top + cornerOffset),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanRect.right - cornerOffset, scanRect.top + cornerLength),
      Offset(scanRect.right - cornerOffset, scanRect.top + cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right - cornerOffset, scanRect.top + cornerOffset),
      Offset(scanRect.right - cornerLength, scanRect.top + cornerOffset),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanRect.left + cornerOffset, scanRect.bottom - cornerLength),
      Offset(scanRect.left + cornerOffset, scanRect.bottom - cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left + cornerOffset, scanRect.bottom - cornerOffset),
      Offset(scanRect.left + cornerLength, scanRect.bottom - cornerOffset),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanRect.right - cornerOffset, scanRect.bottom - cornerLength),
      Offset(scanRect.right - cornerOffset, scanRect.bottom - cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right - cornerOffset, scanRect.bottom - cornerOffset),
      Offset(scanRect.right - cornerLength, scanRect.bottom - cornerOffset),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanningLineAnimation extends StatefulWidget {
  const ScanningLineAnimation({super.key});

  @override
  State<ScanningLineAnimation> createState() => _ScanningLineAnimationState();
}

class _ScanningLineAnimationState extends State<ScanningLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value * 250),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.primaryPurple,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Extension for haptic feedback
extension HapticFeedback on BuildContext {
  static void lightImpact() {
    // In a real app, you would use the haptic_feedback package
    // For now, we'll just print a log
    print('Haptic feedback: light impact');
  }
}
