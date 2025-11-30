// lib/screens/admin/admin_payment_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';
import '../../providers/admin_provider_web.dart';
import '../../providers/theme_provider.dart';

class AdminPaymentManagementScreen extends StatefulWidget {
  const AdminPaymentManagementScreen({super.key});

  @override
  State<AdminPaymentManagementScreen> createState() => _AdminPaymentManagementScreenState();
}

class _AdminPaymentManagementScreenState extends State<AdminPaymentManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Refunds'),
            Tab(text: 'Analytics'),
          ],
          labelColor: context.watch<ThemeProvider>().primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTransactionsTab(),
          _buildRefundsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  'R125,450',
                  Icons.trending_up,
                  AppTheme.greenStatus,
                  '+12% from last month',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending Payments',
                  '8',
                  Icons.pending,
                  AppTheme.goldAccent,
                  'Awaiting confirmation',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed Today',
                  '24',
                  Icons.check_circle,
                  AppTheme.primaryPurple,
                  'R8,450 processed',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Refunds Processed',
                  '3',
                  Icons.refresh,
                  AppTheme.redStatus,
                  'R1,200 refunded',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Transactions
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._getRecentTransactions().map((transaction) => _buildTransactionCard(transaction)),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Process Refunds',
                  Icons.refresh,
                  AppTheme.redStatus,
                  () => _tabController.animateTo(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'View Analytics',
                  Icons.analytics,
                  AppTheme.primaryPurple,
                  () => _tabController.animateTo(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter,
                      decoration: InputDecoration(
                        labelText: 'Filter by Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.filter_list),
                      ),
                      items: [
                        DropdownMenuItem(value: 'all', child: Text('All Transactions')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'failed', child: Text('Failed')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDateRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(_dateRange != null 
                          ? '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
                          : 'Select Date Range'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Transactions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _getFilteredTransactions().length,
            itemBuilder: (context, index) {
              final transaction = _getFilteredTransactions()[index];
              return _buildTransactionCard(transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRefundsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Refund Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Refunds',
                  '5',
                  Icons.pending_actions,
                  AppTheme.goldAccent,
                  'Awaiting approval',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Refunded Today',
                  '2',
                  Icons.check_circle,
                  AppTheme.greenStatus,
                  'R850 processed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Refund Requests
          Text(
            'Refund Requests',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._getRefundRequests().map((refund) => _buildRefundCard(refund)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Chart Placeholder
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Text(
                  'Revenue Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Revenue analytics chart',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Payment Method Distribution
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Methods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 16),
                
                ..._getPaymentMethodStats().map((stat) => _buildPaymentMethodStat(stat)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Top Customers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Customers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 16),
                
                ..._getTopCustomers().map((customer) => _buildTopCustomerCard(customer)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withCustomOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final status = transaction['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: statusColor.withCustomOpacity(0.1),
                child: Icon(
                  _getStatusIcon(status),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['customer'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      transaction['service'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R${transaction['amount'] as String}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withCustomOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payment, color: Colors.grey[600], size: 16),
              const SizedBox(width: 4),
              Text(
                transaction['method'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(Icons.schedule, color: Colors.grey[600], size: 16),
              const SizedBox(width: 4),
              Text(
                transaction['date'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefundCard(Map<String, dynamic> refund) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.goldAccent.withCustomOpacity(0.1),
                child: Icon(Icons.refresh, color: AppTheme.goldAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      refund['customer'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      refund['reason'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R${refund['amount'] as String}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldAccent,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.goldAccent.withCustomOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (refund['status'] as String).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (refund['status'] == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectRefund(refund['id'] as String),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.redStatus),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(color: AppTheme.redStatus),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveRefund(refund['id'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenStatus,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withCustomOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withCustomOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodStat(Map<String, dynamic> stat) {
    final percentage = (stat['count'] as int) / 100 * 100;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat['method'] as String,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: stat['color'] as Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(stat['color'] as Color),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomerCard(Map<String, dynamic> customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryPurple.withCustomOpacity(0.1),
            child: Icon(Icons.person, color: AppTheme.primaryPurple, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${customer['bookings']} bookings',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'R${customer['total'] as String}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRecentTransactions() {
    return [
      {
        'id': '1',
        'customer': 'John Smith',
        'service': 'Office Cleaning',
        'amount': '450.00',
        'method': 'Credit Card',
        'status': 'completed',
        'date': 'Today, 10:30 AM',
      },
      {
        'id': '2',
        'customer': 'Sarah Johnson',
        'service': 'Restaurant Deep Clean',
        'amount': '850.00',
        'method': 'PayPal',
        'status': 'completed',
        'date': 'Today, 9:15 AM',
      },
      {
        'id': '3',
        'customer': 'Mike Wilson',
        'service': 'Medical Facility',
        'amount': '650.00',
        'method': 'Bank Transfer',
        'status': 'pending',
        'date': 'Today, 8:45 AM',
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    final allTransactions = [
      ..._getRecentTransactions(),
      {
        'id': '4',
        'customer': 'Emma Davis',
        'service': 'Home Cleaning',
        'amount': '350.00',
        'method': 'Cash on Arrival',
        'status': 'completed',
        'date': 'Yesterday, 2:30 PM',
      },
      {
        'id': '5',
        'customer': 'Robert Brown',
        'service': 'Window Cleaning',
        'amount': '280.00',
        'method': 'Credit Card',
        'status': 'failed',
        'date': 'Yesterday, 11:00 AM',
      },
    ];

    if (_selectedFilter == 'all') return allTransactions;
    return allTransactions.where((t) => t['status'] == _selectedFilter).toList();
  }

  List<Map<String, dynamic>> _getRefundRequests() {
    return [
      {
        'id': '1',
        'customer': 'Alice Cooper',
        'amount': '450.00',
        'reason': 'Service not satisfactory',
        'status': 'pending',
      },
      {
        'id': '2',
        'customer': 'Bob Martin',
        'amount': '280.00',
        'reason': 'Duplicate payment',
        'status': 'pending',
      },
      {
        'id': '3',
        'customer': 'Carol White',
        'amount': '650.00',
        'reason': 'Cancelled booking',
        'status': 'approved',
      },
    ];
  }

  List<Map<String, dynamic>> _getPaymentMethodStats() {
    return [
      {'method': 'Credit Card', 'count': 45, 'color': AppTheme.primaryPurple},
      {'method': 'PayPal', 'count': 25, 'color': AppTheme.infoBlue},
      {'method': 'Bank Transfer', 'count': 20, 'color': AppTheme.greenStatus},
      {'method': 'Cash on Arrival', 'count': 10, 'color': AppTheme.goldAccent},
    ];
  }

  List<Map<String, dynamic>> _getTopCustomers() {
    return [
      {'name': 'John Smith', 'bookings': 12, 'total': '5,450.00'},
      {'name': 'Sarah Johnson', 'bookings': 8, 'total': '3,200.00'},
      {'name': 'Mike Wilson', 'count': 6, 'total': '2,850.00'},
    ];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.greenStatus;
      case 'pending':
        return AppTheme.goldAccent;
      case 'failed':
        return AppTheme.redStatus;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _approveRefund(String refundId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Refund'),
        content: const Text('Are you sure you want to approve this refund?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refund approved successfully'),
                  backgroundColor: AppTheme.greenStatus,
                ),
              );
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.greenStatus,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectRefund(String refundId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Refund'),
        content: const Text('Are you sure you want to reject this refund?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refund rejected'),
                  backgroundColor: AppTheme.redStatus,
                ),
              );
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redStatus,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
