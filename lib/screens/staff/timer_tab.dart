// lib/screens/staff/timer_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/timekeeping_provider.dart';
// ADD THESE TWO IMPORTS:
import '../../widgets/location_check_dialog.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  final TextEditingController _tempCardController = TextEditingController();

  @override
  void dispose() {
    _tempCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimekeepingProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Job Card
          _buildCurrentJobCard(provider, primaryColor),
          
          const SizedBox(height: 20),
          
          // Temp Card Section
          _buildTempCardSection(provider, primaryColor),
          
          const SizedBox(height: 20),
          
          // Recent Records Section
          _buildRecentRecordsSection(provider, primaryColor),
        ],
      ),
    );
  }

  // Location check before QR scanner
  void _showLocationCheckThenQR(BuildContext context, TimekeepingProvider provider) {
    // Mock job location (in production, get from job data)
    const jobLat = -29.8587; // Durban coordinates
    const jobLon = 31.0218;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationCheckDialog(
        targetLat: jobLat,
        targetLon: jobLon,
        jobAddress: '123 Main St, Durban',
        onVerified: () {
          // Location verified, now show QR scanner
          _showQRScanner(context, provider);
        },
      ),
    );
  }

  Widget _buildCurrentJobCard(TimekeepingProvider provider, Color primaryColor) {
    final hasActiveJob = provider.hasActiveJob;
    final currentJobName = hasActiveJob 
        ? provider.activeJob?.customerName ?? 'Unknown Job'
        : 'No job currently active.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Job',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentJobName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  // CHANGED: Now calls location check first
                  onPressed: hasActiveJob ? null : () => _showLocationCheckThenQR(context, provider),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasActiveJob ? () => _handleCheckOut(provider) : null,
                  icon: const Icon(Icons.logout),
                  label: const Text('Check Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTempCardSection(TimekeepingProvider provider, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temp Card / Proxy Check-In',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'For staff without a phone, supervisor enters their temp card ID (Try: A1B2C3)',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tempCardController,
            decoration: InputDecoration(
              hintText: 'Enter Temp Card ID (e.g., A1B2C3)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleTempCardCheckIn(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Proxy Check-In'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleTempCardCheckOut(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Proxy Check-Out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecordsSection(TimekeepingProvider provider, Color primaryColor) {
    final records = provider.timeRecords.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Time Records',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No time records yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...records.map((record) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            record.jobName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: record.type == 'Self' 
                                ? Colors.blue.shade50 
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: record.type == 'Self' 
                                  ? Colors.blue.shade700 
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Duration: ${record.formattedDuration}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  void _showQRScanner(BuildContext context, TimekeepingProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QRScannerModal(
        onScanned: (jobId) async {
          Navigator.pop(context);
          final success = await provider.checkIn(jobId);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully checked in!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleCheckOut(TimekeepingProvider provider) async {
    final success = await provider.checkOut();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully checked out!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleTempCardCheckIn(TimekeepingProvider provider) async {
    final cardNumber = _tempCardController.text.trim().toUpperCase();
    if (cardNumber.isEmpty) {
      _showError('Please enter a temp card ID');
      return;
    }

    final card = provider.getTempCard(cardNumber);
    if (card == null) {
      _showError('Card ID "$cardNumber" not recognized.');
      return;
    }

    if (provider.hasActiveJob || provider.hasActiveProxy) {
      _showError('Cannot check in. A job is already active.');
      return;
    }

    final success = await provider.checkIn(
      provider.availableJobs.first.id,
      isProxy: true,
      cardNumber: cardNumber,
    );

    if (success && mounted) {
      _tempCardController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PROXY CHECK-IN SUCCESSFUL for ${card.staffName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleTempCardCheckOut(TimekeepingProvider provider) async {
    final cardNumber = _tempCardController.text.trim().toUpperCase();
    if (cardNumber.isEmpty) {
      _showError('Please enter a temp card ID');
      return;
    }

    if (!provider.hasActiveJob) {
      _showError('No job currently active to check out of.');
      return;
    }

    final success = await provider.checkOut(cardNumber: cardNumber);
    if (success && mounted) {
      _tempCardController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PROXY CHECK-OUT SUCCESSFUL'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _QRScannerModal extends StatefulWidget {
  final Function(String) onScanned;

  const _QRScannerModal({required this.onScanned});

  @override
  State<_QRScannerModal> createState() => _QRScannerModalState();
}

class _QRScannerModalState extends State<_QRScannerModal> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan QR Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Scanner
          Expanded(
            child: _isScanning
                ? MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty && _isScanning) {
                        setState(() => _isScanning = false);
                        final String? code = barcodes.first.rawValue;
                        if (code != null) {
                          // Simulate job ID from QR code
                          widget.onScanned('job001');
                        }
                      }
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          
          // Info
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Position the QR code within the frame',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}