// lib/widgets/job_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timekeeping_provider.dart';

class JobSelectionDialog extends StatelessWidget {
  const JobSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimekeepingProvider>();
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Select Job'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: provider.availableJobs.length,
          itemBuilder: (context, index) {
            final job = provider.availableJobs[index];
            return ListTile(
              leading: const Icon(Icons.work_outline),
              title: Text(job.title),
              subtitle: Text(job.location ?? 'No location'),
              onTap: () => Navigator.pop(context, job.id),
            );
          },
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