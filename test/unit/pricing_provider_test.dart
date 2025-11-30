// test/unit/pricing_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/providers/pricing_provider.dart';
import 'package:demo_ncl/models/pricing_model.dart';

void main() {
  group('PricingProvider Tests', () {
    late PricingProvider provider;

    setUp(() {
      provider = PricingProvider();
    });

    tearDown(() {
      provider.resetSelections();
    });

    test('should initialize with default values', () {
      expect(provider.selectedService, ServiceType.regularCleaning);
      expect(provider.selectedPropertySize, PropertySize.medium);
      expect(provider.selectedFrequency, BookingFrequency.oneTime);
      expect(provider.selectedAddOns, isEmpty);
      expect(provider.currentQuote, isNull);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('should update service type and calculate price', () {
      provider.updateServiceType(ServiceType.deepCleaning);
      
      expect(provider.selectedService, ServiceType.deepCleaning);
      expect(provider.currentQuote, isNotNull);
      expect(provider.currentQuote!.serviceType, ServiceType.deepCleaning);
      expect(provider.currentQuote!.basePrice, 150.0);
    });

    test('should update property size and calculate price', () {
      provider.updatePropertySize(PropertySize.large);
      
      expect(provider.selectedPropertySize, PropertySize.large);
      expect(provider.currentQuote, isNotNull);
      expect(provider.currentQuote!.sizeMultiplier, 2.0);
      expect(provider.currentQuote!.subtotal, 160.0); // 80.0 * 2.0
    });

    test('should update frequency and calculate price', () {
      provider.updateFrequency(BookingFrequency.weekly);
      
      expect(provider.selectedFrequency, BookingFrequency.weekly);
      expect(provider.currentQuote, isNotNull);
      expect(provider.currentQuote!.frequencyDiscount, 0.9);
      expect(provider.currentQuote!.discountAmount, closeTo(12.0, 0.01)); // 10% of 120.0 (medium property)
    });

    test('should toggle add-on services', () {
      // Add an add-on
      provider.toggleAddOn(AddOnService.fridgeCleaning);
      expect(provider.selectedAddOns, contains(AddOnService.fridgeCleaning));
      expect(provider.selectedAddOns.length, 1);
      expect(provider.currentQuote!.addOnsTotal, 25.0);

      // Remove the same add-on
      provider.toggleAddOn(AddOnService.fridgeCleaning);
      expect(provider.selectedAddOns, isEmpty);
      expect(provider.currentQuote!.addOnsTotal, 0.0);
    });

    test('should add and remove add-on services', () {
      // Add add-on
      provider.addAddOn(AddOnService.ovenCleaning);
      expect(provider.selectedAddOns, contains(AddOnService.ovenCleaning));
      expect(provider.selectedAddOns.length, 1);

      // Try to add the same add-on again (should not duplicate)
      provider.addAddOn(AddOnService.ovenCleaning);
      expect(provider.selectedAddOns.length, 1);

      // Remove add-on
      provider.removeAddOn(AddOnService.ovenCleaning);
      expect(provider.selectedAddOns, isEmpty);
    });

    test('should clear all add-ons', () {
      provider.addAddOn(AddOnService.fridgeCleaning);
      provider.addAddOn(AddOnService.ovenCleaning);
      expect(provider.selectedAddOns.length, 2);

      provider.clearAddOns();
      expect(provider.selectedAddOns, isEmpty);
    });

    test('should check if add-on is selected', () {
      expect(provider.isAddOnSelected(AddOnService.fridgeCleaning), false);

      provider.addAddOn(AddOnService.fridgeCleaning);
      expect(provider.isAddOnSelected(AddOnService.fridgeCleaning), true);
      expect(provider.isAddOnSelected(AddOnService.ovenCleaning), false);
    });

    test('should calculate price asynchronously', () async {
      await provider.calculatePrice();
      
      expect(provider.isLoading, false);
      expect(provider.currentQuote, isNotNull);
      expect(provider.error, isNull);
    });

    test('should reset all selections', () {
      // Change some values
      provider.updateServiceType(ServiceType.deepCleaning);
      provider.updatePropertySize(PropertySize.large);
      provider.updateFrequency(BookingFrequency.weekly);
      provider.addAddOn(AddOnService.fridgeCleaning);

      // Reset
      provider.resetSelections();

      // Check defaults are restored
      expect(provider.selectedService, ServiceType.regularCleaning);
      expect(provider.selectedPropertySize, PropertySize.medium);
      expect(provider.selectedFrequency, BookingFrequency.oneTime);
      expect(provider.selectedAddOns, isEmpty);
      expect(provider.currentQuote, isNull);
      expect(provider.error, isNull);
    });

    test('should provide available options', () {
      final services = provider.availableServices;
      final propertySizes = provider.availablePropertySizes;
      final frequencies = provider.availableFrequencies;
      final addOns = provider.availableAddOns;

      expect(services.length, 8);
      expect(propertySizes.length, 4);
      expect(frequencies.length, 4);
      expect(addOns.length, 8);

      expect(services, contains(ServiceType.regularCleaning));
      expect(services, contains(ServiceType.deepCleaning));
      expect(propertySizes, contains(PropertySize.small));
      expect(propertySizes, contains(PropertySize.medium));
      expect(frequencies, contains(BookingFrequency.oneTime));
      expect(frequencies, contains(BookingFrequency.weekly));
      expect(addOns, contains(AddOnService.fridgeCleaning));
      expect(addOns, contains(AddOnService.ovenCleaning));
    });

    test('should provide service descriptions', () {
      expect(
        provider.getServiceDescription(ServiceType.regularCleaning),
        'Standard cleaning of all rooms including dusting, vacuuming, and mopping'
      );
      expect(
        provider.getServiceDescription(ServiceType.deepCleaning),
        'Thorough cleaning including baseboards, light fixtures, and hard-to-reach areas'
      );
    });

    test('should provide property size descriptions', () {
      expect(
        provider.getPropertySizeDescription(PropertySize.small),
        'Perfect for apartments and small homes with 1-2 rooms'
      );
      expect(
        provider.getPropertySizeDescription(PropertySize.medium),
        'Ideal for average homes with 3-4 rooms'
      );
    });

    test('should provide frequency descriptions', () {
      expect(
        provider.getFrequencyDescription(BookingFrequency.oneTime),
        'One-time cleaning service'
      );
      expect(
        provider.getFrequencyDescription(BookingFrequency.weekly),
        'Weekly service with 10% discount'
      );
    });

    test('should provide add-on descriptions', () {
      expect(
        provider.getAddOnDescription(AddOnService.fridgeCleaning),
        'Interior and exterior fridge cleaning'
      );
      expect(
        provider.getAddOnDescription(AddOnService.ovenCleaning),
        'Deep oven cleaning including racks'
      );
    });

    test('should validate selections', () {
      // Valid selection (has add-ons)
      provider.addAddOn(AddOnService.fridgeCleaning);
      expect(provider.validateSelections(), isNull);

      // Invalid selection (basic service without add-ons)
      provider.clearAddOns();
      provider.updateServiceType(ServiceType.regularCleaning);
      provider.updatePropertySize(PropertySize.small);
      expect(provider.validateSelections(), isNotNull);
      expect(provider.validateSelections(), contains('Please select additional services'));
    });

    test('should provide pricing summary', () {
      provider.updateServiceType(ServiceType.deepCleaning);
      provider.updatePropertySize(PropertySize.large);
      provider.updateFrequency(BookingFrequency.weekly);
      provider.addAddOn(AddOnService.fridgeCleaning);

      final summary = provider.getPricingSummary();
      
      expect(summary['service'], 'Deep Cleaning');
      expect(summary['propertySize'], 'Large (5-6 rooms)');
      expect(summary['frequency'], 'Weekly');
      expect(summary['addOns'], contains('Fridge Cleaning'));
      expect(summary['basePrice'], '\$150.00');
      expect(summary['subtotal'], '\$325.00'); // 150.0 * 2.0 + 25.0
      expect(summary['discount'], '\$32.50'); // 10% of 325.0
      expect(summary['tax'], startsWith('\$24.')); // 8.5% of (325.0 - 32.5)
      expect(summary['total'], startsWith('\$317.')); // (325.0 - 32.5) + tax
      expect(summary['estimatedHours'], '3.3'); // 2h + 30min*2 + 15min*1 = 3.5h ≈ 3.3h
    });

    test('should handle save and load quote operations', () async {
      provider.updateServiceType(ServiceType.deepCleaning);
      expect(provider.currentQuote, isNotNull);

      // Save quote (should not throw)
      provider.saveQuote();

      // Load quote (should not throw)
      await provider.loadQuote('test_quote_id');
      expect(provider.isLoading, false);
    });

    test('should handle complex pricing scenarios', () {
      // Deep cleaning, extra large property, monthly frequency, multiple add-ons
      provider.updateServiceType(ServiceType.deepCleaning);
      provider.updatePropertySize(PropertySize.extraLarge);
      provider.updateFrequency(BookingFrequency.monthly);
      provider.addAddOn(AddOnService.fridgeCleaning);
      provider.addAddOn(AddOnService.ovenCleaning);

      final quote = provider.currentQuote!;
      
      // Base: 150.0 * 2.5 = 375.0
      // Add-ons: 25.0 + 40.0 = 65.0
      // Subtotal: 375.0 + 65.0 = 440.0
      // Discount: 20% = 88.0
      // Tax: 8.5% of 352.0 = 29.92
      // Total: 381.92
      expect(quote.basePrice, 150.0);
      expect(quote.sizeMultiplier, 2.5);
      expect(quote.subtotal, 440.0);
      expect(quote.addOnsTotal, 65.0);
      expect(quote.discountAmount, closeTo(88.0, 0.01));
      expect(quote.taxAmount, closeTo(29.92, 0.01));
      expect(quote.totalPrice, closeTo(381.92, 0.01));
      expect(quote.estimatedHours, 4.0); // 2h + 30min*3 + 15min*2 = 4h
    });

    test('should format price strings correctly', () {
      provider.updateServiceType(ServiceType.regularCleaning);
      provider.updatePropertySize(PropertySize.small); // Reset to small for base price
      
      final quote = provider.currentQuote!;
      expect(quote.formattedBasePrice, '\$80.00');
      expect(quote.formattedSubtotal, '\$80.00');
      expect(quote.formattedTaxAmount, '\$6.80');
      expect(quote.formattedTotalPrice, '\$86.80');
      expect(quote.formattedDiscount, '\$0.00');
      expect(quote.formattedAddOnsTotal, '\$0.00');
    });
  });
}
