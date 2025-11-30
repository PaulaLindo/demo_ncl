// lib/providers/admin_service_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class AdminServiceProvider extends ChangeNotifier {
  final FirebaseFirestore? _firestore;
  
  List<Service> _allServices = [];
  Set<String> _activeServiceIds = {};
  bool _isLoading = false;
  String? _error;

  List<Service> get allServices => _allServices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminServiceProvider([FirebaseFirestore? firestore]) 
    : _firestore = firestore;

  /// Get all active services
  List<Service> getActiveServices() {
    return _allServices.where((service) => _activeServiceIds.contains(service.id)).toList();
  }

  /// Check if a service is active
  bool isServiceActive(String serviceId) {
    return _activeServiceIds.contains(serviceId);
  }

  /// Load all services and their active status
  Future<void> loadAllServices() async {
    if (_firestore == null) {
      _error = 'Firestore not available in test environment';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load all services
      final servicesSnapshot = await _firestore!.collection('services').get();
      _allServices = servicesSnapshot.docs
          .map((doc) => Service.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Load active service IDs
      final activeSnapshot = await _firestore!.collection('service_settings')
          .doc('active_services')
          .get();
      
      if (activeSnapshot.exists) {
        final data = activeSnapshot.data() as Map<String, dynamic>;
        _activeServiceIds = Set<String>.from(data['active_service_ids'] ?? []);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load services: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new service
  Future<void> addService(Service service) async {
    if (_firestore == null) {
      throw Exception('Firestore not available in test environment');
    }

    try {
      // Add service to Firestore
      await _firestore!.collection('services').doc(service.id).set(service.toJson());
      
      // Add to local list
      _allServices.add(service);
      
      // Activate the new service by default
      await updateServiceStatus(service.id, true);
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }

  /// Update an existing service
  Future<void> updateService(Service service) async {
    if (_firestore == null) {
      throw Exception('Firestore not available in test environment');
    }

    try {
      // Update service in Firestore
      await _firestore!.collection('services').doc(service.id).update(service.toJson());
      
      // Update local list
      final index = _allServices.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _allServices[index] = service;
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  /// Update service status (active/inactive)
  Future<void> updateServiceStatus(String serviceId, bool isActive) async {
    if (_firestore == null) {
      // For testing, just update local state
      if (isActive) {
        _activeServiceIds.add(serviceId);
      } else {
        _activeServiceIds.remove(serviceId);
      }
      notifyListeners();
      return;
    }

    try {
      final docRef = _firestore!.collection('service_settings').doc('active_services');
      
      await _firestore!.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        Set<String> activeIds;
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          activeIds = Set<String>.from(data['active_service_ids'] ?? []);
        } else {
          activeIds = <String>{};
        }

        if (isActive) {
          activeIds.add(serviceId);
        } else {
          activeIds.remove(serviceId);
        }

        if (snapshot.exists) {
          transaction.update(docRef, {'active_service_ids': activeIds.toList()});
        } else {
          transaction.set(docRef, {'active_service_ids': activeIds.toList()});
        }
      });

      // Update local state
      if (isActive) {
        _activeServiceIds.add(serviceId);
      } else {
        _activeServiceIds.remove(serviceId);
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update service status: $e');
    }
  }

  /// Delete a service
  Future<void> deleteService(String serviceId) async {
    if (_firestore == null) {
      throw Exception('Firestore not available in test environment');
    }

    try {
      // Delete from Firestore
      await _firestore!.collection('services').doc(serviceId).delete();
      
      // Remove from active services
      await updateServiceStatus(serviceId, false);
      
      // Remove from local list
      _allServices.removeWhere((service) => service.id == serviceId);
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  /// Bulk update service statuses
  Future<void> bulkUpdateServiceStatus(Map<String, bool> serviceStatuses) async {
    if (_firestore == null) {
      // For testing, just update local state
      serviceStatuses.forEach((serviceId, isActive) {
        if (isActive) {
          _activeServiceIds.add(serviceId);
        } else {
          _activeServiceIds.remove(serviceId);
        }
      });
      notifyListeners();
      return;
    }

    try {
      final docRef = _firestore!.collection('service_settings').doc('active_services');
      
      await _firestore!.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        Set<String> activeIds;
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          activeIds = Set<String>.from(data['active_service_ids'] ?? []);
        } else {
          activeIds = <String>{};
        }

        // Update each service status
        serviceStatuses.forEach((serviceId, isActive) {
          if (isActive) {
            activeIds.add(serviceId);
          } else {
            activeIds.remove(serviceId);
          }
        });

        if (snapshot.exists) {
          transaction.update(docRef, {'active_service_ids': activeIds.toList()});
        } else {
          transaction.set(docRef, {'active_service_ids': activeIds.toList()});
        }
      });

      // Update local state
      serviceStatuses.forEach((serviceId, isActive) {
        if (isActive) {
          _activeServiceIds.add(serviceId);
        } else {
          _activeServiceIds.remove(serviceId);
        }
      });
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to bulk update service statuses: $e');
    }
  }

  /// Get service statistics
  Map<String, int> getServiceStatistics() {
    final totalServices = _allServices.length;
    final activeServices = _activeServiceIds.length;
    final inactiveServices = totalServices - activeServices;
    
    final categoryStats = <String, int>{};
    for (final service in _allServices) {
      categoryStats[service.category] = (categoryStats[service.category] ?? 0) + 1;
    }

    return {
      'total': totalServices,
      'active': activeServices,
      'inactive': inactiveServices,
      ...categoryStats,
    };
  }

  /// Search services
  List<Service> searchServices(String query) {
    if (query.isEmpty) return _allServices;
    
    final lowercaseQuery = query.toLowerCase();
    return _allServices.where((service) {
      return service.name.toLowerCase().contains(lowercaseQuery) ||
          service.description.toLowerCase().contains(lowercaseQuery) ||
          service.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get services by category
  List<Service> getServicesByCategory(String category) {
    return _allServices.where((service) => service.category == category).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Methods for testing
  void setServices(List<Service> services) {
    _allServices = services;
    _activeServiceIds = Set.from(services.map((s) => s.id));
    notifyListeners();
  }

  void setActiveServices(Set<String> activeIds) {
    _activeServiceIds = activeIds;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }
}
