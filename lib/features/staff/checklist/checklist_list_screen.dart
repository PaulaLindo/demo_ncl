// lib/features/staff/checklists/checklist_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../utils/color_utils.dart';

import 'checklist_provider.dart';
import 'checklist_detail_screen.dart';
import '../../../models/checklist_model.dart';

class ChecklistListScreen extends StatelessWidget {
  const ChecklistListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Checklists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ChecklistProvider>().loadChecklists(),
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.checklists.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadChecklists(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.checklists.isEmpty) {
            return const Center(child: Text('No checklists available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.checklists.length,
            itemBuilder: (context, index) {
              final checklist = provider.checklists[index];
              return _ChecklistCard(checklist: checklist);
            },
          );
        },
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final CleaningChecklist checklist;

  const _ChecklistCard({super.key, required this.checklist});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Add haptic feedback
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => 
                  ChecklistDetailScreen(checklistId: checklist.id),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withCustomOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.cleaning_services,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checklist.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${checklist.clientName} • ${_formatTimeRemaining(checklist.scheduledTime)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: checklist.status),
                ],
              ),
              const SizedBox(height: 16),
              // Add a visual progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: checklist.completionPercentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(checklist.status).withCustomOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${checklist.completedItems} of ${checklist.totalItems} tasks',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${(checklist.completionPercentage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(checklist.status),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRemaining(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
    return 'Now';
  }

  Color _getStatusColor(ChecklistStatus status) {
    switch (status) {
      case ChecklistStatus.pending:
        return Colors.redAccent;
      case ChecklistStatus.inProgress:
        return Colors.blueAccent;
      case ChecklistStatus.completed:
        return Colors.greenAccent;
      case ChecklistStatus.verified:
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final ChecklistStatus status;

  const _StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusText() {
    return status.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ChecklistStatus.pending:
        return Colors.red[100]!;
      case ChecklistStatus.inProgress:
        return Colors.blue[100]!;
      case ChecklistStatus.completed:
        return Colors.green[100]!;
      case ChecklistStatus.verified:
        return Colors.purple[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case ChecklistStatus.pending:
        return Colors.orange[800]!;
      case ChecklistStatus.inProgress:
        return Colors.blue[800]!;
      case ChecklistStatus.completed:
        return Colors.green[800]!;
      case ChecklistStatus.verified:
        return Colors.purple[800]!;
    }
  }
}