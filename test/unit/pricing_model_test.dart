// test/unit/pricing_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/pricing_model.dart';

void main() {
  group('PricingModel Tests', () {
    group('ServiceType', () {
      test('should have correct display names and base prices', () {
        expect(ServiceType.regularCleaning.displayName, 'Regular Cleaning');
        expect(ServiceType.regularCleaning.basePrice, 80.0);
        expect(ServiceType.deepCleaning.displayName, 'Deep Cleaning');
        expect(ServiceType.deepCleaning.basePrice, 150.0);
      });

      test('should contain all expected service types', () {
        final services = ServiceType.values;
        expect(services.length, 8);
        expect(services, contains(ServiceType.regularCleaning));
        expect(services, contains(ServiceType.deepCleaning));
        expect(services, contains(ServiceType.windowCleaning));
        expect(services, contains(ServiceType.carpetCleaning));
      });
    });

    group('PropertySize', () {
      test('should have correct multipliers', () {
        expect(PropertySize.small.multiplier, 1.0);
        expect(PropertySize.medium.multiplier, 1.5);
        expect(PropertySize.large.multiplier, 2.0);
        expect(PropertySize.extraLarge.multiplier, 2.5);
      });

      test('should have correct display names', () {
        expect(PropertySize.small.displayName, 'Small (1-2 rooms)');
        expect(PropertySize.medium.displayName, 'Medium (3-4 rooms)');
      });
    });

    group('BookingFrequency', () {
      test('should have correct discount multipliers', () {
        expect(BookingFrequency.oneTime.discountMultiplier, 1.0);
        expect(BookingFrequency.weekly.discountMultiplier, 0.9);
        expect(BookingFrequency.biWeekly.discountMultiplier, 0.85);
        expect(BookingFrequency.monthly.discountMultiplier, 0.8);
      });
    });

    group('AddOnService', () {
      test('should have correct prices and display names', () {
        expect(AddOnService.fridgeCleaning.price, 25.0);
        expect(AddOnService.fridgeCleaning.displayName, 'Fridge Cleaning');
        expect(AddOnService.ovenCleaning.price, 40.0);
        expect(AddOnService.ovenCleaning.displayName, 'Oven Cleaning');
      });
    });

    group('PriceQuote', () {
      test('should calculate basic price correctly', () {
        final quote = PriceQuote.calculate(
          serviceType: ServiceType.regularCleaning,
          propertySize: PropertySize.small,
          frequency: BookingFrequency.oneTime,
        );

        expect(quote.serviceType, ServiceType.regularCleaning);
        expect(quote.propertySize, PropertySize.small);
        expect(quote.frequency, BookingFrequency.oneTime);
        expect(quote.basePrice, 80.0);
        expect(quote.sizeMultiplier, 1.0);
        expect(quote.subtotal, 80.0);
        expect(quote.addOnsTotal, 0.0);
        expect(quote.discountAmount, 0.0);
      });

      test('should apply property size multiplier correctly', () {
        final quote = PriceQuote.calculate(
          serviceType: ServiceType.regularCleaning,
          propertySize: PropertySize.large,
          frequency: BookingFrequency.oneTime,
        );

        expect(quote.sizeMultiplier, 2.0);
        expect(quote.subtotal, 160.0); // 80.0 * 2.0
      });

      test('should apply frequency discount correctly', () {
        final quote = PriceQuote.calculate(
          serviceType: ServiceType.regularCleaning,
          propertySize: PropertySize.small,
          frequency: BookingFrequency.weekly,
        );

        expect(quote.frequencyDiscount, 0.9);
        expect(quote.discountAmount, closeTo(8.0, 0.01));
      });

      test('should calculate add-ons correctly', () {
        final quote = PriceQuote.calculate(
          serviceType: ServiceType.regularCleaning,
          propertySize: PropertySize.small,
          frequency: BookingFrequency.oneTime,
          addOns: [AddOnService.fridgeCleaning, AddOnService.ovenCleaning],
        );

        expect(quote.addOnsTotal, 65.0); // 25.0 + 40.0
        expect(quote.subtotal, 145.0); // 80.0 + 65.0
      });

      test('should calculate tax correctly', () {
        final quote = PriceQuote.calculate(
          serviceType: ServiceType.regularCleaning,
          propertySize: PropertySize.small,
          frequency: BookingFrequency.oneTime,
        );

        expect(quote.taxRate, 0.085);
        expect(quote.taxAmount, closeTo(6.8, 0.01));
        expect(quote.totalPrice, closeTo(86.8, 0.01));
      });

      test('should calculate complex pricing scenario', () {
        final quote = PriceQuote.calculate(
          serviceType: ServiceType.deepCleaning,
          propertySize: PropertySize.large,
          frequency: BookingFrequency.monthly,
          addOns: [AddOnService.fridgeCleaning],
        );

        // Base: 150.0 * 2.0 = 300.0
        // Add-on: +25.0 = 325.0
        // Discount: 20% off = 260.0
        // Tax: 8.5% = 22.1
        // Total: 282.1
        expect(quote.basePrice, 150.0);
        expect(quote.subtotal, 325.0);
        expect(quote.discountAmount, closeTo(65.0, 0.01));
        expect(quote.taxAmount, closeTo(22.1, 0.01));
        expect(quote.totalPrice, closeTo(282.1, 0.01));
      });

      test('should format price strings correctly', () {
        final quote = PriceQuote.calculate(
          serviceType: ServiceType.regularCleaning,
          propertySize: PropertySize.small,
          frequency: BookingFrequency.oneTime,
        );

        expect(quote.formattedBasePrice, '\$80.00');
        expect(quote.formattedSubtotal, '\$80.00');
        expect(quote.formattedTaxAmount, '\$6.80');
        expect(quote.formattedTotalPrice, '\$86.80');
        expect(quote.formattedDiscount, '\$0.00');
        expect(quote.formattedAddOnsTotal, '\$0.00');
      });

      test('should estimate duration correctly', () {
        final quote = PriceQuote.calculate(
          serviceType: ServiceType.regularCleaning,
          propertySize: PropertySize.small,
          frequency: BookingFrequency.oneTime,
        );

        expect(quote.estimatedHours, 2.0); // Base 2 hours for small regular cleaning
      });

      test('should serialize to and from JSON', () {
        final originalQuote = PriceQuote.calculate(
          serviceType: ServiceType.deepCleaning,
          propertySize: PropertySize.large,
          frequency: BookingFrequency.weekly,
          addOns: [AddOnService.fridgeCleaning],
        );

        final json = originalQuote.toJson();
        final deserializedQuote = PriceQuote.fromJson(json);

        expect(deserializedQuote.serviceType, originalQuote.serviceType);
        expect(deserializedQuote.propertySize, originalQuote.propertySize);
        expect(deserializedQuote.frequency, originalQuote.frequency);
        expect(deserializedQuote.totalPrice, originalQuote.totalPrice);
        expect(deserializedQuote.addOns.length, originalQuote.addOns.length);
      });
    });
  });
}
