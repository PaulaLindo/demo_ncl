// lib/providers/pricing_provider.dart
import 'package:flutter/foundation.dart';
import '../models/pricing_model.dart';
import '../models/service_model.dart';

class PricingProvider extends ChangeNotifier {
  ServiceType _selectedService = ServiceType.regularCleaning;
  PropertySize _selectedPropertySize = PropertySize.medium;
  BookingFrequency _selectedFrequency = BookingFrequency.oneTime;
  List<AddOnService> _selectedAddOns = [];
  PriceQuote? _currentQuote;
  bool _isLoading = false;
  String? _error;

  // Getters
  ServiceType get selectedService => _selectedService;
  PropertySize get selectedPropertySize => _selectedPropertySize;
  BookingFrequency get selectedFrequency => _selectedFrequency;
  List<AddOnService> get selectedAddOns => List.unmodifiable(_selectedAddOns);
  PriceQuote? get currentQuote => _currentQuote;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Update selections
  void updateServiceType(ServiceType serviceType) {
    _selectedService = serviceType;
    _calculatePrice();
    notifyListeners();
  }

  void updatePropertySize(PropertySize propertySize) {
    _selectedPropertySize = propertySize;
    _calculatePrice();
    notifyListeners();
  }

  void updateFrequency(BookingFrequency frequency) {
    _selectedFrequency = frequency;
    _calculatePrice();
    notifyListeners();
  }

  void toggleAddOn(AddOnService addOn) {
    if (_selectedAddOns.contains(addOn)) {
      _selectedAddOns.remove(addOn);
    } else {
      _selectedAddOns.add(addOn);
    }
    _calculatePrice();
    notifyListeners();
  }

  void addAddOn(AddOnService addOn) {
    if (!_selectedAddOns.contains(addOn)) {
      _selectedAddOns.add(addOn);
      _calculatePrice();
      notifyListeners();
    }
  }

  void removeAddOn(AddOnService addOn) {
    if (_selectedAddOns.contains(addOn)) {
      _selectedAddOns.remove(addOn);
      _calculatePrice();
      notifyListeners();
    }
  }

  void clearAddOns() {
    _selectedAddOns.clear();
    _calculatePrice();
    notifyListeners();
  }

  void resetSelections() {
    _selectedService = ServiceType.regularCleaning;
    _selectedPropertySize = PropertySize.medium;
    _selectedFrequency = BookingFrequency.oneTime;
    _selectedAddOns.clear();
    _currentQuote = null;
    _error = null;
    notifyListeners();
  }

  // Calculate price
  Future<void> calculatePrice() async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      _currentQuote = PriceQuote.calculate(
        serviceType: _selectedService,
        propertySize: _selectedPropertySize,
        frequency: _selectedFrequency,
        addOns: _selectedAddOns,
      );

      _setLoading(false);
    } catch (e) {
      _setError('Failed to calculate price: $e');
      _setLoading(false);
    }
  }

  void _calculatePrice() {
    _currentQuote = PriceQuote.calculate(
      serviceType: _selectedService,
      propertySize: _selectedPropertySize,
      frequency: _selectedFrequency,
      addOns: _selectedAddOns,
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Get available options
  List<ServiceType> get availableServices => ServiceType.values;
  List<PropertySize> get availablePropertySizes => PropertySize.values;
  List<BookingFrequency> get availableFrequencies => BookingFrequency.values;
  List<AddOnService> get availableAddOns => AddOnService.values;

  // Utility methods
  bool isAddOnSelected(AddOnService addOn) => _selectedAddOns.contains(addOn);

  String getServiceDescription(ServiceType service) {
    switch (service) {
      case ServiceType.regularCleaning:
        return 'Standard cleaning of all rooms including dusting, vacuuming, and mopping';
      case ServiceType.deepCleaning:
        return 'Thorough cleaning including baseboards, light fixtures, and hard-to-reach areas';
      case ServiceType.windowCleaning:
        return 'Interior and exterior window cleaning with streak-free guarantee';
      case ServiceType.carpetCleaning:
        return 'Professional carpet steam cleaning and stain treatment';
      case ServiceType.kitchenCleaning:
        return 'Deep kitchen cleaning including appliances, cabinets, and countertops';
      case ServiceType.bathroomCleaning:
        return 'Thorough bathroom sanitization including tiles, grout, and fixtures';
      case ServiceType.moveInOutCleaning:
        return 'Complete cleaning for moving in or out, including empty spaces';
      case ServiceType.postConstruction:
        return 'Post-construction cleanup including dust removal and debris clearing';
    }
  }

  String getPropertySizeDescription(PropertySize size) {
    switch (size) {
      case PropertySize.small:
        return 'Perfect for apartments and small homes with 1-2 rooms';
      case PropertySize.medium:
        return 'Ideal for average homes with 3-4 rooms';
      case PropertySize.large:
        return 'Great for larger homes with 5-6 rooms';
      case PropertySize.extraLarge:
        return 'Best for very large homes with 7+ rooms';
    }
  }

  String getFrequencyDescription(BookingFrequency frequency) {
    switch (frequency) {
      case BookingFrequency.oneTime:
        return 'One-time cleaning service';
      case BookingFrequency.weekly:
        return 'Weekly service with 10% discount';
      case BookingFrequency.biWeekly:
        return 'Bi-weekly service with 15% discount';
      case BookingFrequency.monthly:
        return 'Monthly service with 20% discount';
    }
  }

  String getAddOnDescription(AddOnService addOn) {
    switch (addOn) {
      case AddOnService.fridgeCleaning:
        return 'Interior and exterior fridge cleaning';
      case AddOnService.ovenCleaning:
        return 'Deep oven cleaning including racks';
      case AddOnService.cabinetCleaning:
        return 'Interior and exterior cabinet cleaning';
      case AddOnService.balconyCleaning:
        return 'Balcony floor and railing cleaning';
      case AddOnService.garageCleaning:
        return 'Garage floor and organization cleaning';
      case AddOnService.basementCleaning:
        return 'Basement cleaning and dust removal';
      case AddOnService.wallWashing:
        return 'Interior wall washing and spot cleaning';
      case AddOnService.furnitureCleaning:
        return 'Upholstery and furniture cleaning';
    }
  }

  // Save/load quote
  void saveQuote() {
    if (_currentQuote != null) {
      // In a real app, this would save to local storage or backend
      debugPrint('Quote saved: ${_currentQuote!.toJson()}');
    }
  }

  Future<void> loadQuote(String quoteId) async {
    _setLoading(true);
    try {
      // In a real app, this would load from local storage or backend
      await Future.delayed(const Duration(milliseconds: 300));
      // Mock loading - would implement actual storage
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load quote: $e');
      _setLoading(false);
    }
  }

  // Validate selections
  String? validateSelections() {
    if (_selectedService == ServiceType.regularCleaning && 
        _selectedPropertySize == PropertySize.small && 
        _selectedAddOns.isEmpty) {
      return 'Please select additional services or upgrade your package';
    }
    return null;
  }

  // Get pricing summary
  Map<String, dynamic> getPricingSummary() {
    if (_currentQuote == null) return {};
    
    return {
      'service': _currentQuote!.serviceType.displayName,
      'propertySize': _currentQuote!.propertySize.displayName,
      'frequency': _currentQuote!.frequency.displayName,
      'addOns': _currentQuote!.addOns.map((e) => e.displayName).toList(),
      'basePrice': _currentQuote!.formattedBasePrice,
      'subtotal': _currentQuote!.formattedSubtotal,
      'discount': _currentQuote!.formattedDiscount,
      'tax': _currentQuote!.formattedTaxAmount,
      'total': _currentQuote!.formattedTotalPrice,
      'estimatedHours': _currentQuote!.estimatedHours.toStringAsFixed(1),
    };
  }

  /// Generate a fixed-price quote for a booking request
  Future<Quote> generateFixedPriceQuote(dynamic bookingRequest) async {
    _setLoading(true);
    try {
      // Calculate base price from services
      double basePrice = 0.0;
      Map<String, dynamic> breakdown = {};
      
      for (final service in bookingRequest.services) {
        final quantity = bookingRequest.serviceQuantities[service.id] ?? 1;
        final serviceTotal = service.basePrice * quantity;
        basePrice += serviceTotal;
        
        breakdown[service.name] = {
          'quantity': quantity,
          'unitPrice': service.basePrice,
          'total': serviceTotal,
        };
        
        // Add add-ons
        final addons = bookingRequest.serviceAddons[service.id] ?? [];
        for (final addonId in addons) {
          final addon = service.availableAddons.firstWhere(
            (a) => a.id == addonId,
            orElse: () => ServiceAddon(id: '', name: '', price: 0.0),
          );
          final addonTotal = addon.price * quantity;
          basePrice += addonTotal;
          
          breakdown['${service.name} - ${addon.name}'] = {
            'quantity': quantity,
            'unitPrice': addon.price,
            'total': addonTotal,
          };
        }
      }
      
      // Add pet fee if applicable
      if (bookingRequest.hasPets) {
        basePrice += 25.0;
        breakdown['Pet Fee'] = {'quantity': 1, 'unitPrice': 25.0, 'total': 25.0};
      }
      
      // Apply frequency discount
      double finalPrice = basePrice;
      String? discountText;
      if (bookingRequest.frequency != 'One-time') {
        final discount = basePrice * 0.1; // 10% discount
        finalPrice -= discount;
        discountText = '${bookingRequest.frequency} discount (10%)';
        breakdown['Discount'] = {'amount': discount, 'description': discountText};
      }
      
      // Create quote options
      final options = [
        QuoteOption(
          id: 'standard',
          name: 'Standard Service',
          description: 'Our standard cleaning service with quality guarantee',
          totalPrice: finalPrice,
          features: [
            'Professional cleaning staff',
            'Quality guarantee',
            'Standard cleaning supplies',
            '2-hour service window',
          ],
        ),
        QuoteOption(
          id: 'premium',
          name: 'Premium Service',
          description: 'Enhanced service with additional benefits',
          totalPrice: finalPrice * 1.2, // 20% premium
          features: [
            'Professional cleaning staff',
            'Premium quality guarantee',
            'Eco-friendly cleaning supplies',
            '1-hour service window',
            'Priority scheduling',
            'Detailed post-service report',
          ],
          savingsText: 'Best value for peace of mind',
        ),
        QuoteOption(
          id: 'economy',
          name: 'Economy Service',
          description: 'Budget-friendly option with essential cleaning',
          totalPrice: finalPrice * 0.9, // 10% economy discount
          features: [
            'Professional cleaning staff',
            'Standard quality guarantee',
            'Basic cleaning supplies',
            '4-hour service window',
          ],
          savingsText: 'Save 10% with flexible timing',
        ),
      ];
      
      final quote = Quote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        basePrice: basePrice,
        availableOptions: options,
        validUntil: DateTime.now().add(const Duration(days: 7)),
        breakdown: breakdown,
        notes: 'Quote valid for 7 days. Price fixed once booking is confirmed.',
      );
      
      _setLoading(false);
      return quote;
    } catch (e) {
      _setError('Failed to generate quote: $e');
      _setLoading(false);
      rethrow;
    }
  }
}
