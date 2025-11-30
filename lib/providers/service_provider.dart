// lib/providers/service_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import 'admin_service_provider.dart';

class ServiceProvider extends ChangeNotifier {
  final FirebaseFirestore? _firestore;
  final AdminServiceProvider _adminServiceProvider;
  
  List<Service> _availableServices = [];
  bool _isLoading = false;
  String? _error;

  ServiceProvider([AdminServiceProvider? adminServiceProvider, FirebaseFirestore? firestore]) 
    : _adminServiceProvider = adminServiceProvider ?? AdminServiceProvider(null),
      _firestore = firestore;

  List<Service> get availableServices => _availableServices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all available services (only active ones)
  Future<void> loadServices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load services from admin provider to get active status
      await _adminServiceProvider.loadAllServices();
      
      // Get only active services
      _availableServices = _adminServiceProvider.getActiveServices();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load services: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get services by category
  List<Service> getServicesByCategory(String category) {
    return _availableServices
        .where((service) => service.category == category)
        .toList();
  }

  /// Get popular services
  List<Service> getPopularServices() {
    return _availableServices
        .where((service) => service.isPopular)
        .toList();
  }

  /// Get featured services
  List<Service> getFeaturedServices() {
    return _availableServices
        .where((service) => service.isFeatured)
        .toList();
  }

  /// Search services by name or description
  List<Service> searchServices(String query) {
    if (query.isEmpty) return _availableServices;
    
    final lowercaseQuery = query.toLowerCase();
    return _availableServices.where((service) {
      return service.name.toLowerCase().contains(lowercaseQuery) ||
          service.description.toLowerCase().contains(lowercaseQuery) ||
          service.features.any((feature) => 
              feature.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get service by ID
  Service? getServiceById(String id) {
    try {
      return _availableServices.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
