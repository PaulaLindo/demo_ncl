// lib/widgets/quality_gate_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/timekeeping_provider.dart';
import '../theme/app_theme.dart';
import '../models/time_record_model.dart';
import '../utils/color_utils.dart';

class QualityGateDialog extends StatefulWidget {
  const QualityGateDialog({
    super.key,
    required this.timeRecord,
    this.onApproved,
    this.onRejected,
  });

  final TimeRecord timeRecord;
  final VoidCallback? onApproved;
  final VoidCallback? onRejected;

  @override
  State<QualityGateDialog> createState() => _QualityGateDialogState();
}

class _QualityGateDialogState extends State<QualityGateDialog> {
  final List<QualityCheckItem> _checkItems = [
    QualityCheckItem(
      id: 'cleaning_completed',
      title: 'All cleaning tasks completed',
      description: 'Verify that all required cleaning tasks have been completed',
      isRequired: true,
    ),
    QualityCheckItem(
      id: 'customer_satisfied',
      title: 'Customer satisfaction confirmed',
      description: 'Customer has confirmed satisfaction with the work',
      isRequired: true,
    ),
    QualityCheckItem(
      id: 'supplies_restocked',
      title: 'Supplies restocked',
      description: 'Cleaning supplies have been restocked and organized',
      isRequired: false,
    ),
    QualityCheckItem(
      id: 'issues_reported',
      title: 'Issues documented',
      description: 'Any issues or concerns have been properly documented',
      isRequired: false,
    ),
    QualityCheckItem(
      id: 'photos_taken',
      title: 'Before/after photos taken',
      description: 'Photographic evidence of work completed has been captured',
      isRequired: false,
    ),
  ];

  final TextEditingController _notesController = TextEditingController();
  final List<String> _selectedIssues = [];
  bool _customerSatisfied = true;
  int _customerRating = 5;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canClockOut {
    final requiredChecks = _checkItems.where((item) => item.isRequired);
    return requiredChecks.every((item) => item.isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quality Check Before Clock Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Job: ${widget.timeRecord.jobName}',
                          style: TextStyle(
                            color: Colors.white.withCustomOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time summary
                    _buildTimeSummary(),
                    
                    const SizedBox(height: 24),
                    
                    // Quality checks
                    Text(
                      'Quality Checklist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._checkItems.map((item) => _buildCheckItem(item)),
                    
                    const SizedBox(height: 24),
                    
                    // Customer satisfaction
                    _buildCustomerSatisfaction(),
                    
                    const SizedBox(height: 24),
                    
                    // Issues/Notes
                    _buildNotesSection(),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  // Warning if required items not checked
                  if (!_canClockOut)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withCustomOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withCustomOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please complete all required quality checks before clocking out',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onRejected?.call();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: AppTheme.redStatus),
                            ),
                            child: Text(
                              'Report Issue',
                              style: TextStyle(color: AppTheme.redStatus),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _canClockOut
                                ? () {
                                    Navigator.of(context).pop();
                                    widget.onApproved?.call();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.greenStatus,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Clock Out',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSummary() {
    final duration = DateTime.now().difference(widget.timeRecord.checkInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppTheme.primaryPurple),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Session',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${hours}h ${minutes}m',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(QualityCheckItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CheckboxListTile(
          value: item.isChecked,
          onChanged: (value) {
            setState(() {
              item.isChecked = value ?? false;
            });
          },
          title: Row(
            children: [
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (item.isRequired)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.redStatus,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Required',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            item.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildCustomerSatisfaction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Satisfaction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          // Satisfaction toggle
          Row(
            children: [
              Switch(
                value: _customerSatisfied,
                onChanged: (value) {
                  setState(() {
                    _customerSatisfied = value;
                    // Auto-check customer satisfaction item
                    final customerItem = _checkItems.firstWhere(
                      (item) => item.id == 'customer_satisfied',
                    );
                    customerItem.isChecked = value;
                  });
                },
                activeColor: AppTheme.greenStatus,
              ),
              const SizedBox(width: 12),
              Text(
                _customerSatisfied ? 'Customer Satisfied' : 'Customer Issues',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _customerSatisfied ? AppTheme.greenStatus : AppTheme.redStatus,
                ),
              ),
            ],
          ),
          
          if (_customerSatisfied) ...[
            const SizedBox(height: 16),
            Text(
              'Customer Rating',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _customerRating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _customerRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        
        // Common issues
        Text(
          'Common Issues (select all that apply):',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Missing supplies',
            'Equipment malfunction',
            'Customer unavailable',
            'Access issues',
            'Extra time needed',
            'Other',
          ].map((issue) {
            final isSelected = _selectedIssues.contains(issue);
            return FilterChip(
              label: Text(issue),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedIssues.add(issue);
                  } else {
                    _selectedIssues.remove(issue);
                  }
                });
              },
              selectedColor: AppTheme.primaryPurple.withCustomOpacity(0.2),
              checkmarkColor: AppTheme.primaryPurple,
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Notes field
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any additional notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}

class QualityCheckItem {
  final String id;
  final String title;
  final String description;
  final bool isRequired;
  bool isChecked;

  QualityCheckItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isRequired,
    this.isChecked = false,
  });
}
