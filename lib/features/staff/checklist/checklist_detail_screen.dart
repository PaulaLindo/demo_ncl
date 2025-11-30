// lib/features/staff/checklists/checklist_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:demo_ncl/providers/checklist_provider.dart';
import 'package:demo_ncl/utils/color_utils.dart';
import 'package:demo_ncl/models/checklist_model.dart';

class ChecklistDetailScreen extends StatefulWidget{
  final String checklistId;

  const ChecklistDetailScreen({super.key, required this.checklistId});

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistProvider>(
      builder: (context, provider, _) {
        final checklist = provider.checklists.firstWhere(
          (c) => c.id == widget.checklistId,
          orElse: () => throw Exception('Checklist not found'),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(checklist.title),
            actions: [
              if (checklist.isCompleted)
                const IconButton(
                  icon: Icon(Icons.check_circle),
                  onPressed: null,
                  tooltip: 'Completed',
                ),
            ],
          ),
          body: Column(
            children: [
              _buildHeader(context, checklist),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: checklist.items.length,
                  itemBuilder: (context, index) {
                    return _ChecklistItem(
                      item: checklist.items[index],
                      onToggle: () => provider.toggleChecklistItem(
                        checklist.id,
                        checklist.items[index].id,
                      ),
                      onAddPhoto: () => _handleAddPhoto(
                        context,
                        checklist.id,
                        checklist.items[index].id,
                      ),
                    );
                  },
                ),
              ),
              if (!checklist.isCompleted) _buildSubmitButton(context, checklist),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CleaningChecklist checklist) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withCustomOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client: ${checklist.clientName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text('Address: ${checklist.clientAddress}'),
          const SizedBox(height: 4),
          Text(
            'Scheduled: ${DateFormat('MMM d, y • h:mm a').format(checklist.scheduledTime)}',
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: checklist.completionPercentage,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${checklist.completedItems} of ${checklist.totalItems} tasks',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${(checklist.completionPercentage * 100).toInt()}% Complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, CleaningChecklist checklist) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (checklist.completionPercentage < 1.0)
            Column(
              children: [
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Add notes (optional)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
              ],
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _submitChecklist(context, checklist),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Submit Checklist'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitChecklist(
      BuildContext context, CleaningChecklist checklist) async {
    if (checklist.completionPercentage < 1.0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Checklist'),
          content: const Text(
              'Not all tasks are marked as completed. Are you sure you want to submit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit Anyway'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);

    if (!mounted) return;
    
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<ChecklistProvider>();
    
    final success = await provider.submitChecklist(
          checklist.id,
          _notesController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Checklist submitted successfully')),
        );
        navigator.pop();
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to submit checklist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAddPhoto(
      BuildContext context, String checklistId, String itemId) async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () async {
                final photo = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (context.mounted) {
                  Navigator.pop(context, photo);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final photo = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (context.mounted) {
                  Navigator.pop(context, photo);
                }
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      // In a real app, you would upload the image to a server
      // For now, we'll just save it locally
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy(
        '${appDir.path}/$fileName',
      );

      if (mounted) {
        final provider = context.read<ChecklistProvider>();
        provider.addPhotoToItem(
              checklistId,
              itemId,
              savedImage.path,
            );
      }
    }
  }
}

class _ChecklistItem extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onToggle;
  final VoidCallback onAddPhoto;

  const _ChecklistItem({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: item.isCompleted,
                  onChanged: (_) => onToggle(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                ),
                if (item.photoRequired != null || item.photoPath != null)
                  IconButton(
                    icon: Icon(
                      item.photoPath != null
                          ? Icons.photo_camera
                          : Icons.add_a_photo,
                      color: item.photoPath != null
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    onPressed: onAddPhoto,
                    tooltip: item.photoPath != null
                        ? 'View photo'
                        : 'Add photo (${item.photoRequired})',
                  ),
              ],
            ),
            if (item.description != null) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (item.photoPath != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(item.photoPath!),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}