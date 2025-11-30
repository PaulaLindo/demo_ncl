// test/unit/payment_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/payment_model.dart';

void main() {
  group('PaymentModel Tests', () {
    group('PaymentMethod', () {
      test('should have correct display names', () {
        expect(PaymentMethod.creditCard.displayName, 'Credit Card');
        expect(PaymentMethod.debitCard.displayName, 'Debit Card');
        expect(PaymentMethod.paypal.displayName, 'PayPal');
        expect(PaymentMethod.applePay.displayName, 'Apple Pay');
        expect(PaymentMethod.googlePay.displayName, 'Google Pay');
        expect(PaymentMethod.bankTransfer.displayName, 'Bank Transfer');
      });

      test('should contain all expected payment methods', () {
        final methods = PaymentMethod.values;
        expect(methods.length, 6);
        expect(methods, contains(PaymentMethod.creditCard));
        expect(methods, contains(PaymentMethod.debitCard));
        expect(methods, contains(PaymentMethod.paypal));
        expect(methods, contains(PaymentMethod.applePay));
        expect(methods, contains(PaymentMethod.googlePay));
        expect(methods, contains(PaymentMethod.bankTransfer));
      });
    });

    group('PaymentStatus', () {
      test('should have correct display names', () {
        expect(PaymentStatus.pending.displayName, 'Pending');
        expect(PaymentStatus.processing.displayName, 'Processing');
        expect(PaymentStatus.completed.displayName, 'Completed');
        expect(PaymentStatus.failed.displayName, 'Failed');
        expect(PaymentStatus.cancelled.displayName, 'Cancelled');
        expect(PaymentStatus.refunded.displayName, 'Refunded');
      });
    });

    group('PaymentCurrency', () {
      test('should have correct properties', () {
        expect(PaymentCurrency.usd.value, 'USD');
        expect(PaymentCurrency.usd.displayName, 'US Dollar');
        expect(PaymentCurrency.usd.symbol, '\$');
        
        expect(PaymentCurrency.eur.value, 'EUR');
        expect(PaymentCurrency.eur.displayName, 'Euro');
        expect(PaymentCurrency.eur.symbol, '€');
        
        expect(PaymentCurrency.gbp.value, 'GBP');
        expect(PaymentCurrency.gbp.displayName, 'British Pound');
        expect(PaymentCurrency.gbp.symbol, '£');
        
        expect(PaymentCurrency.cad.value, 'CAD');
        expect(PaymentCurrency.cad.displayName, 'Canadian Dollar');
        expect(PaymentCurrency.cad.symbol, 'C\$');
      });
    });

    group('Payment', () {
      test('should create payment with required properties', () {
        final createdAt = DateTime(2024, 1, 15, 10, 0);
        final payment = Payment(
          id: 'payment_123',
          bookingId: 'booking_456',
          amount: 150.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.pending,
          createdAt: createdAt,
        );

        expect(payment.id, 'payment_123');
        expect(payment.bookingId, 'booking_456');
        expect(payment.amount, 150.0);
        expect(payment.currency, PaymentCurrency.usd);
        expect(payment.method, PaymentMethod.creditCard);
        expect(payment.status, PaymentStatus.pending);
        expect(payment.createdAt, createdAt);
      });

      test('should create payment using factory constructor', () {
        final payment = Payment.create(
          bookingId: 'booking_456',
          amount: 200.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.paypal,
          metadata: {'test': 'data'},
        );

        expect(payment.id, startsWith('payment_'));
        expect(payment.bookingId, 'booking_456');
        expect(payment.amount, 200.0);
        expect(payment.method, PaymentMethod.paypal);
        expect(payment.status, PaymentStatus.pending);
        expect(payment.metadata!['test'], 'data');
      });

      test('should format amount correctly', () {
        final payment = Payment(
          id: 'payment_123',
          bookingId: 'booking_456',
          amount: 150.50,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          createdAt: DateTime.now(),
        );

        expect(payment.formattedAmount, '\$150.50');
      });

      test('should check payment status correctly', () {
        final completedPayment = Payment(
          id: 'payment_1',
          bookingId: 'booking_1',
          amount: 100.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          createdAt: DateTime.now(),
        );

        final failedPayment = Payment(
          id: 'payment_2',
          bookingId: 'booking_2',
          amount: 100.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.failed,
          createdAt: DateTime.now(),
        );

        final pendingPayment = Payment(
          id: 'payment_3',
          bookingId: 'booking_3',
          amount: 100.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(completedPayment.isCompleted, true);
        expect(completedPayment.isFailed, false);
        expect(completedPayment.isPending, false);

        expect(failedPayment.isCompleted, false);
        expect(failedPayment.isFailed, true);
        expect(failedPayment.isPending, false);

        expect(pendingPayment.isCompleted, false);
        expect(pendingPayment.isFailed, false);
        expect(pendingPayment.isPending, true);
      });

      test('should update status with withStatus method', () {
        final originalPayment = Payment(
          id: 'payment_123',
          bookingId: 'booking_456',
          amount: 150.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.pending,
          createdAt: DateTime(2024, 1, 15, 10, 0),
        );

        final completedPayment = originalPayment.withStatus(
          PaymentStatus.completed,
          transactionId: 'txn_123456',
          gatewayResponse: '{"status": "success"}',
        );

        expect(completedPayment.id, originalPayment.id);
        expect(completedPayment.status, PaymentStatus.completed);
        expect(completedPayment.transactionId, 'txn_123456');
        expect(completedPayment.gatewayResponse, '{"status": "success"}');
        expect(completedPayment.processedAt, isNotNull);
        expect(completedPayment.completedAt, isNotNull);
      });

      test('should calculate processing duration', () {
        final processedAt = DateTime(2024, 1, 15, 10, 5);
        final completedAt = DateTime(2024, 1, 15, 10, 7);
        
        final payment = Payment(
          id: 'payment_123',
          bookingId: 'booking_456',
          amount: 150.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          createdAt: DateTime(2024, 1, 15, 10, 0),
          processedAt: processedAt,
          completedAt: completedAt,
        );

        expect(payment.processingDuration?.inMinutes, 2);
      });

      test('should serialize to and from JSON', () {
        final originalPayment = Payment(
          id: 'payment_123',
          bookingId: 'booking_456',
          amount: 150.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          createdAt: DateTime(2024, 1, 15, 10, 0),
          processedAt: DateTime(2024, 1, 15, 10, 5),
          completedAt: DateTime(2024, 1, 15, 10, 7),
          transactionId: 'txn_123456',
          gatewayResponse: '{"status": "success"}',
          metadata: {'test': 'data'},
        );

        final json = originalPayment.toJson();
        final deserializedPayment = Payment.fromJson(json);

        expect(deserializedPayment.id, originalPayment.id);
        expect(deserializedPayment.bookingId, originalPayment.bookingId);
        expect(deserializedPayment.amount, originalPayment.amount);
        expect(deserializedPayment.status, originalPayment.status);
        expect(deserializedPayment.transactionId, originalPayment.transactionId);
        expect(deserializedPayment.metadata!['test'], originalPayment.metadata!['test']);
      });
    });

    group('PaymentMethodDetails', () {
      test('should create payment method details', () {
        final paymentMethod = PaymentMethodDetails(
          type: PaymentMethod.creditCard,
          lastFour: '1234',
          expiryMonth: '12',
          expiryYear: '25',
          cardholderName: 'John Doe',
          brand: 'Visa',
          isDefault: true,
          addedAt: DateTime(2024, 1, 15),
        );

        expect(paymentMethod.type, PaymentMethod.creditCard);
        expect(paymentMethod.lastFour, '1234');
        expect(paymentMethod.expiryMonth, '12');
        expect(paymentMethod.expiryYear, '25');
        expect(paymentMethod.cardholderName, 'John Doe');
        expect(paymentMethod.brand, 'Visa');
        expect(paymentMethod.isDefault, true);
      });

      test('should format display text correctly', () {
        final creditCard = PaymentMethodDetails(
          type: PaymentMethod.creditCard,
          lastFour: '1234',
          brand: 'Visa',
        );

        final paypal = PaymentMethodDetails(
          type: PaymentMethod.paypal,
        );

        final applePay = PaymentMethodDetails(
          type: PaymentMethod.applePay,
        );

        expect(creditCard.displayText, 'Visa ****1234');
        expect(paypal.displayText, 'PayPal');
        expect(applePay.displayText, 'Apple Pay');
      });

      test('should format expiry date correctly', () {
        final paymentMethod = PaymentMethodDetails(
          type: PaymentMethod.creditCard,
          lastFour: '1234',
          expiryMonth: '12',
          expiryYear: '25',
        );

        expect(paymentMethod.expiryDisplay, '12/25');
      });

      test('should serialize to and from JSON', () {
        final originalMethod = PaymentMethodDetails(
          type: PaymentMethod.creditCard,
          lastFour: '1234',
          expiryMonth: '12',
          expiryYear: '25',
          cardholderName: 'John Doe',
          brand: 'Visa',
          isDefault: true,
          addedAt: DateTime(2024, 1, 15),
        );

        final json = originalMethod.toJson();
        final deserializedMethod = PaymentMethodDetails.fromJson(json);

        expect(deserializedMethod.type, originalMethod.type);
        expect(deserializedMethod.lastFour, originalMethod.lastFour);
        expect(deserializedMethod.brand, originalMethod.brand);
        expect(deserializedMethod.isDefault, originalMethod.isDefault);
      });
    });

    group('PaymentResult', () {
      test('should create successful payment result', () {
        final payment = Payment(
          id: 'payment_123',
          bookingId: 'booking_456',
          amount: 150.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          createdAt: DateTime.now(),
        );

        final result = PaymentResult.success(payment, metadata: {'test': 'data'});

        expect(result.success, true);
        expect(result.payment, payment);
        expect(result.error, null);
        expect(result.errorCode, null);
        expect(result.metadata!['test'], 'data');
      });

      test('should create failed payment result', () {
        final result = PaymentResult.failure(
          'Insufficient funds',
          errorCode: 'DECLINED',
          metadata: {'attempt': 1},
        );

        expect(result.success, false);
        expect(result.payment, null);
        expect(result.error, 'Insufficient funds');
        expect(result.errorCode, 'DECLINED');
        expect(result.metadata!['attempt'], 1);
      });
    });

    group('RefundStatus', () {
      test('should have correct display names', () {
        expect(RefundStatus.pending.displayName, 'Pending');
        expect(RefundStatus.processing.displayName, 'Processing');
        expect(RefundStatus.completed.displayName, 'Completed');
        expect(RefundStatus.failed.displayName, 'Failed');
      });
    });

    group('Refund', () {
      test('should create refund with required properties', () {
        final refund = Refund(
          id: 'refund_123',
          paymentId: 'payment_456',
          amount: 50.0,
          reason: 'Customer requested refund',
          status: RefundStatus.pending,
          createdAt: DateTime(2024, 1, 15, 10, 0),
        );

        expect(refund.id, 'refund_123');
        expect(refund.paymentId, 'payment_456');
        expect(refund.amount, 50.0);
        expect(refund.reason, 'Customer requested refund');
        expect(refund.status, RefundStatus.pending);
      });
    });
  });
}
