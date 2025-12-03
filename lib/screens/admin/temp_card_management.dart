// lib/screens/admin/temp_card_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/temp_card_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/admin_provider_web.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_manager.dart';

class TempCardManagementPage extends StatefulWidget {
  const TempCardManagementPage({Key? key}) : super(key: key);

  @override
  State<TempCardManagementPage> createState() => _TempCardManagementPageState();
}

class _TempCardManagementPageState extends State<TempCardManagementPage> {
  late ThemeProvider themeProvider;
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _staffNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load temp cards when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProviderWeb>().loadTempCards();
    });
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    _staffNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProviderWeb>();
    themeProvider = context.watch<ThemeProvider>();
    final backgroundColor = themeProvider.backgroundColor;

    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Temproray Card Management'),
          backgroundColor: themeProvider.cardColor,
          foregroundColor: themeProvider.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: () => _showIssueTempCardDialog(context),
              icon: const Icon(Icons.add),
              tooltip: 'Issue New Temp Card',
            ),
          ],
        ),
        body: Consumer<AdminProviderWeb>(
          builder: (context, adminProvider, _) {
            if (adminProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final tempCards = adminProvider.tempCards;

            if (tempCards.isEmpty) {
              return const Center(child: Text('No temporary cards found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tempCards.length,
              itemBuilder: (context, index) {
                final tempCard = tempCards[index];
                return _buildTempCardCard(context, tempCard, adminProvider);
              },
            );
          },
        ),
      );
    }

  Widget _buildTempCardCard(
    BuildContext context,
    TempCard tempCard,
    AdminProviderWeb provider,
  ) {
    final isExpired = DateTime.now().isAfter(tempCard.expiryDate);
    final isActive = tempCard.isActive && !isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (isActive)
                  IconButton(
                    onPressed: () => _showDeactivateDialog(context, tempCard, provider),
                    icon: const Icon(Icons.block, color: Colors.red),
                    tooltip: 'Deactivate',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.credit_card, color: themeProvider.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Card: ${tempCard.cardNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Staff: ${tempCard.userName}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Issued: ${tempCard.issueDate.toString().substring(0, 10)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (isExpired)
                  Text(
                    'EXPIRED',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Expires: ${tempCard.expiryDate.toString().substring(0, 10)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            if (tempCard.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${tempCard.notes}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (tempCard.deactivationReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deactivated: ${tempCard.deactivationReason}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showIssueTempCardDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue New Temp Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _staffIdController,
              decoration: const InputDecoration(
                labelText: 'Staff ID',
                hintText: 'Enter staff ID',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _staffNameController,
              decoration: const InputDecoration(
                labelText: 'Staff Name',
                hintText: 'Enter staff name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional notes',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_staffIdController.text.isEmpty || _staffNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final provider = context.read<AdminProviderWeb>();
                final tempCard = await provider.issueTempCard(
                  staffId: _staffIdController.text,
                  staffName: _staffNameController.text,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );
                
                // Clear the form
                _staffIdController.clear();
                _staffNameController.clear();
                _notesController.clear();
                
                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Temporary card issued: ${tempCard.cardNumber}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                Navigator.of(context).pop();
                _staffIdController.clear();
                _staffNameController.clear();
                _notesController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Temp card issued: ${tempCard.cardNumber}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Issue Card'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, TempCard tempCard, AdminProviderWeb provider) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Temp Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Card: ${tempCard.cardNumber}'),
            Text('Staff: ${tempCard.userName}'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Deactivation Reason',
                hintText: 'Enter reason for deactivation',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a deactivation reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await provider.deactivateTempCard(tempCard.id, reasonController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Temp card deactivated'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}
