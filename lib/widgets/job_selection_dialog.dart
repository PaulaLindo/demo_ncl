// lib/widgets/job_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timekeeping_provider.dart';

class JobSelectionDialog extends StatelessWidget {
  final String? qrCode;
  
  const JobSelectionDialog({super.key, this.qrCode});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimekeepingProvider>();
    final theme = Theme.of(context);
    
    // Find job that matches QR code if provided
    final matchedJob = qrCode != null 
        ? provider.availableJobs.firstWhere(
            (job) => job.id == qrCode || job.qrCode == qrCode,
            orElse: () => null,
          )
        : null;

    // If we have a QR code and it matches a job, auto-select it after a short delay
    if (matchedJob != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pop(context, matchedJob.id);
      });
    }

    return AlertDialog(
      title: const Text('Select Job'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (qrCode != null && matchedJob == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'No job found for QR code: $qrCode',
                  style: TextStyle(color: Colors.orange[800]),
                ),
              ),
            if (matchedJob != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Found matching job:',
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            if (matchedJob != null)
              Card(
                color: theme.primaryColor.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.qr_code, color: Colors.green),
                  title: Text(matchedJob.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(matchedJob.location ?? 'No location'),
                  onTap: () => Navigator.pop(context, matchedJob.id),
                ),
              ),
            if (provider.availableJobs.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Or select a different job:'),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.availableJobs.length,
              itemBuilder: (context, index) {
                final job = provider.availableJobs[index];
                if (job.id == matchedJob?.id) return const SizedBox.shrink();
                
                return ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: Text(job.title),
                  subtitle: Text(job.location ?? 'No location'),
                  onTap: () => Navigator.pop(context, job.id),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}