// lib/screens/admin/admin_service_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_service_provider.dart';
import '../../models/service_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class AdminServiceManagementScreen extends StatefulWidget {
  const AdminServiceManagementScreen({super.key});

  @override
  State<AdminServiceManagementScreen> createState() => _AdminServiceManagementScreenState();
}

class _AdminServiceManagementScreenState extends State<AdminServiceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers for adding/editing services
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _showAddServiceForm = false;
  Service? _editingService;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _pricingUnit = 'per job';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AdminServiceProvider>().loadAllServices();
    } catch (e) {
      _showErrorSnackBar('Failed to load services: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddServiceForm) {
      return _buildServiceForm();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Management'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active Services'),
            Tab(text: 'All Services'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServices,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveServicesTab(),
          _buildAllServicesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveServicesTab() {
    return Consumer<AdminServiceProvider>(
      builder: (context, provider, child) {
        final activeServices = provider.getActiveServices();
        final filteredServices = _filterServices(activeServices);

        return Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredServices.isEmpty
                      ? const Center(
                          child: Text('No active services found'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return _buildServiceCard(service, isActive: true);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllServicesTab() {
    return Consumer<AdminServiceProvider>(
      builder: (context, provider, child) {
        final allServices = provider.allServices;
        final filteredServices = _filterServices(allServices);

        return Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredServices.isEmpty
                      ? const Center(
                          child: Text('No services found'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return _buildServiceCard(service, isActive: false);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Core Cleaning', 'Home Care', 'Specialty'].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primaryPurple.withCustomOpacity(0.2),
                    checkmarkColor: AppTheme.primaryPurple,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Service> _filterServices(List<Service> services) {
    var filtered = services;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((s) => s.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
          s.name.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  Widget _buildServiceCard(Service service, {required bool isActive}) {
    final provider = context.read<AdminServiceProvider>();
    final isServiceActive = provider.isServiceActive(service.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withCustomOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: service.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            service.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.cleaning_services,
                                color: AppTheme.primaryPurple,
                                size: 30,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.cleaning_services,
                          color: AppTheme.primaryPurple,
                          size: 30,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${service.basePrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: isServiceActive,
                      onChanged: (value) async {
                        await _toggleServiceStatus(service, value);
                      },
                    ),
                    Text(
                      isServiceActive ? 'Active' : 'Inactive',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isServiceActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (service.features.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: service.features.take(3).map((feature) {
                  return Chip(
                    label: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    backgroundColor: Colors.grey[100],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editService(service),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                if (!isActive)
                  TextButton.icon(
                    onPressed: () => _deleteService(service),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleServiceStatus(Service service, bool isActive) async {
    try {
      await context.read<AdminServiceProvider>().updateServiceStatus(
            service.id,
            isActive,
          );
      _showSuccessSnackBar(
        isActive ? 'Service activated successfully' : 'Service deactivated successfully',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update service status: $e');
    }
  }

  void _showAddServiceDialog() {
    setState(() {
      _showAddServiceForm = true;
      _editingService = null;
      _clearForm();
    });
  }

  void _editService(Service service) {
    setState(() {
      _showAddServiceForm = true;
      _editingService = service;
      _populateForm(service);
    });
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _durationController.clear();
    _categoryController.clear();
    _imageUrlController.clear();
  }

  void _populateForm(Service service) {
    _nameController.text = service.name;
    _descriptionController.text = service.description;
    _priceController.text = service.basePrice.toString();
    _durationController.text = service.duration ?? '';
    _categoryController.text = service.category;
    _imageUrlController.text = service.imageUrl ?? '';
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final serviceData = Service(
        id: _editingService?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        basePrice: double.tryParse(_priceController.text) ?? 0.0,
        category: _categoryController.text.trim(),
        duration: _durationController.text.trim().isEmpty ? null : _durationController.text.trim(),
        pricingUnit: _pricingUnit,
        createdAt: _editingService?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_editingService != null) {
        await context.read<AdminServiceProvider>().updateService(serviceData);
        _showSuccessSnackBar('Service updated successfully');
      } else {
        await context.read<AdminServiceProvider>().addService(serviceData);
        _showSuccessSnackBar('Service added successfully');
      }

      setState(() {
        _showAddServiceForm = false;
        _editingService = null;
        _clearForm();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to save service: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteService(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<AdminServiceProvider>().deleteService(service.id);
        _showSuccessSnackBar('Service deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to delete service: $e');
      }
    }
  }

  Widget _buildServiceForm() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingService != null ? 'Edit Service' : 'Add Service'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _showAddServiceForm = false;
                _editingService = null;
                _clearForm();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter service name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Base Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (e.g., 2 hours)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_editingService != null ? 'Update Service' : 'Add Service'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
