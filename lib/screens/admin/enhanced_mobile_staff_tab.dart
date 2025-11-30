// lib/screens/admin/enhanced_mobile_staff_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/staff_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/color_utils.dart';
import '../../../models/job_model.dart';

class EnhancedMobileStaffTab extends StatefulWidget {
  const EnhancedMobileStaffTab({super.key});

  @override
  State<EnhancedMobileStaffTab> createState() => _EnhancedMobileStaffTabState();
}

class _EnhancedMobileStaffTabState extends State<EnhancedMobileStaffTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _staffMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStaffMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStaffMembers() async {
    setState(() => _isLoading = true);
    
    // Mock staff data
    _staffMembers = [
      {
        'id': '1',
        'name': 'Mike Wilson',
        'email': 'mike.wilson@ncl.com',
        'phone': '+1234567892',
        'department': 'Cleaning',
        'position': 'Senior Cleaner',
        'status': 'active',
        'rating': 4.8,
        'jobsCompleted': 156,
        'joinDate': DateTime.now().subtract(const Duration(days: 90)),
        'lastLogin': DateTime.now().subtract(const Duration(hours: 6)),
        'availability': 'available',
        'nextShift': DateTime.now().add(const Duration(hours: 4)),
        'certifications': ['Professional Cleaning', 'Safety Training'],
        'salary': 45000,
        'performance': 'excellent',
      },
      {
        'id': '2',
        'name': 'Sarah Brown',
        'email': 'sarah.brown@ncl.com',
        'phone': '+1234567893',
        'department': 'Cleaning',
        'position': 'Cleaner',
        'status': 'inactive',
        'rating': 4.5,
        'jobsCompleted': 89,
        'joinDate': DateTime.now().subtract(const Duration(days: 45)),
        'lastLogin': DateTime.now().subtract(const Duration(days: 7)),
        'availability': 'unavailable',
        'nextShift': null,
        'certifications': ['Professional Cleaning'],
        'salary': 38000,
        'performance': 'good',
      },
      {
        'id': '3',
        'name': 'Tom Johnson',
        'email': 'tom.johnson@ncl.com',
        'phone': '+1234567895',
        'department': 'Specialized',
        'position': 'Window Specialist',
        'status': 'active',
        'rating': 4.9,
        'jobsCompleted': 234,
        'joinDate': DateTime.now().subtract(const Duration(days: 180)),
        'lastLogin': DateTime.now().subtract(const Duration(hours: 2)),
        'availability': 'on-duty',
        'nextShift': DateTime.now().add(const Duration(hours: 8)),
        'certifications': ['Window Cleaning', 'High-Rise Safety'],
        'salary': 52000,
        'performance': 'excellent',
      },
      {
        'id': '4',
        'name': 'Lisa Davis',
        'email': 'lisa.davis@ncl.com',
        'phone': '+1234567896',
        'department': 'Specialized',
        'position': 'Carpet Specialist',
        'status': 'active',
        'rating': 4.7,
        'jobsCompleted': 178,
        'joinDate': DateTime.now().subtract(const Duration(days: 120)),
        'lastLogin': DateTime.now().subtract(const Duration(hours: 1)),
        'availability': 'available',
        'nextShift': DateTime.now().add(const Duration(days: 1)),
        'certifications': ['Carpet Cleaning', 'Stain Removal'],
        'salary': 48000,
        'performance': 'excellent',
      },
      {
        'id': '5',
        'name': 'James Miller',
        'email': 'james.miller@ncl.com',
        'phone': '+1234567897',
        'department': 'Management',
        'position': 'Team Lead',
        'status': 'active',
        'rating': 4.6,
        'jobsCompleted': 0,
        'joinDate': DateTime.now().subtract(const Duration(days: 365)),
        'lastLogin': DateTime.now().subtract(const Duration(minutes: 30)),
        'availability': 'available',
        'nextShift': DateTime.now().add(const Duration(hours: 6)),
        'certifications': ['Leadership', 'Safety Management'],
        'salary': 65000,
        'performance': 'excellent',
      },
    ];
    
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredStaff {
    var filtered = _staffMembers;
    
    if (_selectedDepartment != 'All') {
      filtered = filtered.where((staff) => staff['department'] == _selectedDepartment).toList();
    }
    
    if (_selectedStatus != 'All') {
      filtered = filtered.where((staff) => staff['status'] == _selectedStatus).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((staff) => 
        staff['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
        staff['email'].toString().toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.firstName ?? 'Admin';

    return Column(
      children: [
        // Header
        _buildHeader(userName),
        
        // Search and Filter
        _buildSearchAndFilter(),
        
        // Tab Bar
        _buildTabBar(),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStaffList(),
              _buildScheduleView(),
              _buildPerformanceView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String userName) {
    final totalStaff = _staffMembers.length;
    final activeStaff = _staffMembers.where((s) => s['status'] == 'active').length;
    final availableStaff = _staffMembers.where((s) => s['availability'] == 'available').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF334155),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withCustomOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staff Management',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Manage staff schedules and performance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withCustomOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat('Total', '$totalStaff', Icons.people),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderStat('Active', '$activeStaff', Icons.check_circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderStat('Available', '$availableStaff', Icons.event_available),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withCustomOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withCustomOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search staff members...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filters Row
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown('Department', _selectedDepartment, ['All', 'Cleaning', 'Specialized', 'Management']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown('Status', _selectedStatus, ['All', 'active', 'inactive']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (label == 'Department') {
                _selectedDepartment = value!;
              } else {
                _selectedStatus = value!;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: const Color(0xFF1E293B),
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Staff'),
          Tab(text: 'Schedule'),
          Tab(text: 'Performance'),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final staff = _filteredStaff;
    
    if (staff.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No staff found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: staff.length,
      itemBuilder: (context, index) {
        final staffMember = staff[index];
        return _buildStaffCard(staffMember);
      },
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staffMember) {
    final statusColor = staffMember['status'] == 'active' ? AppTheme.greenStatus : AppTheme.redStatus;
    final availabilityColor = _getAvailabilityColor(staffMember['availability']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and availability
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    staffMember['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withCustomOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        staffMember['status'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: availabilityColor.withCustomOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        staffMember['availability'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: availabilityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Staff details
            Row(
              children: [
                Icon(
                  Icons.work,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '${staffMember['position']} • ${staffMember['department']}',
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
                Icon(
                  Icons.email,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    staffMember['email'],
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
                Icon(
                  Icons.phone,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  staffMember['phone'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.star,
                  size: 16,
                  color: AppTheme.goldAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${staffMember['rating']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            
            // Stats row
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppTheme.greenStatus,
                ),
                const SizedBox(width: 4),
                Text(
                  '${staffMember['jobsCompleted']} jobs',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Joined ${DateFormat('MMM yyyy').format(staffMember['joinDate'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            // Next shift info
            if (staffMember['nextShift'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppTheme.primaryPurple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next shift: ${DateFormat('MMM dd, h:mm a').format(staffMember['nextShift'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            
            // Action buttons
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  'View',
                  Icons.visibility,
                  Colors.blue,
                  () => _viewStaffDetails(staffMember),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  'Schedule',
                  Icons.calendar_today,
                  AppTheme.primaryPurple,
                  () => _manageSchedule(staffMember),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  'Message',
                  Icons.message,
                  AppTheme.secondaryColor,
                  () => _messageStaff(staffMember),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildScheduleView() {
    final todayShifts = _staffMembers.where((s) => 
      s['nextShift'] != null && _isSameDay(s['nextShift'], DateTime.now())
    ).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          if (todayShifts.isEmpty)
            _buildEmptyState('No shifts scheduled for today', 'Staff shifts will appear here')
          else
            ...todayShifts.map((shift) => _buildShiftCard(shift)).toList(),
          
          const SizedBox(height: 24),
          
          Text(
            'Upcoming Shifts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Column(
            children: [
              Builder(
                builder: (context) {
                  final upcomingShifts = _staffMembers
                    .where((s) => s['nextShift'] != null && !_isSameDay(s['nextShift'], DateTime.now()))
                    .toList();
                  upcomingShifts.sort((a, b) => (a['nextShift'] as DateTime).compareTo(b['nextShift'] as DateTime));
                  final topUpcoming = upcomingShifts.take(5).toList();
                  
                  return Column(
                    children: topUpcoming.map((shift) => _buildShiftCard(shift)).toList(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(Map<String, dynamic> staffMember) {
    final shift = staffMember['nextShift'];
    final availabilityColor = _getAvailabilityColor(staffMember['availability']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: availabilityColor.withCustomOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person,
              color: availabilityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staffMember['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${staffMember['position']} • ${staffMember['department']}',
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
                DateFormat('h:mm a').format(shift),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                DateFormat('MMM dd').format(shift),
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

  Widget _buildPerformanceView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Top performers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Performers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                
                Column(
                  children: [
                    Builder(
                      builder: (context) {
                        final sortedStaff = _staffMembers
                          .where((s) => s['rating'] != null)
                          .toList();
                        sortedStaff.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
                        final topStaff = sortedStaff.take(5).toList();
                        
                        return Column(
                          children: topStaff.map((staff) => _buildPerformanceItem(staff)).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Department performance
          Text(
            'Department Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          ...['Cleaning', 'Specialized', 'Management'].map((department) {
            final deptStaff = _staffMembers.where((s) => s['department'] == department).toList();
            final avgRating = deptStaff.isEmpty ? 0.0 : 
              deptStaff.fold<double>(0, (sum, s) => sum + (s['rating'] as double)) / deptStaff.length;
            final totalJobs = deptStaff.fold<int>(0, (sum, s) => sum + (s['jobsCompleted'] as int));
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          department,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${deptStaff.length} staff members',
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
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppTheme.goldAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$totalJobs jobs',
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
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(Map<String, dynamic> staffMember) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              staffMember['name'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: AppTheme.goldAccent,
              ),
              const SizedBox(width: 4),
              Text(
                '${staffMember['rating']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${staffMember['jobsCompleted']} jobs',
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

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvailabilityColor(String availability) {
    switch (availability.toLowerCase()) {
      case 'available':
        return AppTheme.greenStatus;
      case 'on-duty':
        return AppTheme.infoBlue;
      case 'unavailable':
        return AppTheme.redStatus;
      default:
        return Colors.grey;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _viewStaffDetails(Map<String, dynamic> staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staffMember['name']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Position', staffMember['position']),
              _buildDetailRow('Department', staffMember['department']),
              _buildDetailRow('Email', staffMember['email']),
              _buildDetailRow('Phone', staffMember['phone']),
              _buildDetailRow('Status', staffMember['status']),
              _buildDetailRow('Rating', '${staffMember['rating']}'),
              _buildDetailRow('Jobs Completed', '${staffMember['jobsCompleted']}'),
              _buildDetailRow('Join Date', DateFormat('MMM dd, yyyy').format(staffMember['joinDate'])),
              _buildDetailRow('Last Login', _getLastLoginText(staffMember['lastLogin'])),
              if (staffMember['nextShift'] != null)
                _buildDetailRow('Next Shift', DateFormat('MMM dd, h:mm a').format(staffMember['nextShift'])),
              _buildDetailRow('Salary', '\$${staffMember['salary'].toStringAsFixed(0)}'),
              _buildDetailRow('Performance', staffMember['performance']),
              if (staffMember['certifications'] != null)
                _buildDetailRow('Certifications', staffMember['certifications'].join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _manageSchedule(staffMember);
            },
            child: const Text('Manage Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getLastLoginText(DateTime? lastLogin) {
    if (lastLogin == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastLogin);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(lastLogin);
    }
  }

  void _manageSchedule(Map<String, dynamic> staffMember) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Managing schedule for ${staffMember['name']}...'),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  void _messageStaff(Map<String, dynamic> staffMember) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${staffMember['name']}...'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }
}
