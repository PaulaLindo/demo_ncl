// lib/screens/admin/b2b_lead_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../models/b2b_lead_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class B2BLeadManagementPage extends StatefulWidget {
  const B2BLeadManagementPage({super.key});

  @override
  State<B2BLeadManagementPage> createState() => _B2BLeadManagementPageState();
}

class _B2BLeadManagementPageState extends State<B2BLeadManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Lead Management'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showAddLeadDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add New Lead',
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<B2BLead>>(
            stream: provider.leadsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final leads = snapshot.data ?? [];

              if (leads.isEmpty) {
                return const Center(
                  child: Text('No B2B leads yet'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return _buildLeadCard(context, lead, provider);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLeadCard(
    BuildContext context,
    B2BLead lead,
    AdminProvider provider,
  ) {
    final statusColor = _getStatusColor(lead.status);

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
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lead.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<LeadStatus>(
                  onSelected: (status) => _updateLeadStatus(context, lead, status, provider),
                  itemBuilder: (context) => LeadStatus.values.map((status) {
                    return PopupMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.business, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lead.companyName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                  'Contact: ${lead.contactName}',
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
                Icon(Icons.email, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lead.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  lead.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Interest: ${lead.serviceInterest}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
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
                  'Created: ${lead.createdAt.toString().substring(0, 10)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (lead.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${lead.notes}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return Colors.blue;
      case LeadStatus.contacted:
        return Colors.orange;
      case LeadStatus.qualified:
        return Colors.purple;
      case LeadStatus.proposal:
        return Colors.indigo;
      case LeadStatus.negotiation:
        return Colors.teal;
      case LeadStatus.won:
        return Colors.green;
      case LeadStatus.lost:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddLeadDialog(BuildContext context) {
    final companyNameController = TextEditingController();
    final contactNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final serviceInterestController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New B2B Lead'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Enter company name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'Enter contact person name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: serviceInterestController,
                decoration: const InputDecoration(
                  labelText: 'Service Interest',
                  hintText: 'e.g., Regular Cleaning, Deep Clean, Post-Construction',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional notes',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (companyNameController.text.isEmpty ||
                  contactNameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  serviceInterestController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final provider = context.read<AdminProvider>();
                await provider.addB2BLead(
                  companyName: companyNameController.text,
                  contactName: contactNameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  serviceInterest: serviceInterestController.text,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('B2B lead added'),
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
            child: const Text('Add Lead'),
          ),
        ],
      ),
    );
  }

  void _updateLeadStatus(
    BuildContext context,
    B2BLead lead,
    LeadStatus newStatus,
    AdminProvider provider,
  ) {
    if (newStatus == lead.status) return;

    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status to ${newStatus.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Company: ${lead.companyName}'),
            Text('Current Status: ${lead.status.displayName}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Status Update Notes (Optional)',
                hintText: 'Add notes about this status change',
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
              try {
                await provider.updateLeadStatus(
                  lead.id,
                  newStatus,
                  notesController.text.isEmpty ? null : notesController.text,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status updated to ${newStatus.displayName}'),
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
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
