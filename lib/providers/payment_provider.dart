// lib/providers/payment_provider.dart
import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../models/pricing_model.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Payment> _payments = [];
  List<PaymentMethodDetails> _savedPaymentMethods = [];
  PaymentMethodDetails? _defaultPaymentMethod;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Payment> get payments => List.unmodifiable(_payments);
  List<PaymentMethodDetails> get savedPaymentMethods => List.unmodifiable(_savedPaymentMethods);
  PaymentMethodDetails? get defaultPaymentMethod => _defaultPaymentMethod;

  // Process a payment
  Future<PaymentResult> processPayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    required PaymentCurrency currency,
    Map<String, dynamic>? paymentDetails,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Create payment record
      final payment = Payment.create(
        bookingId: bookingId,
        amount: amount,
        currency: currency,
        method: method,
        metadata: paymentDetails,
      );

      // Add to payments list
      _payments.insert(0, payment);

      // Simulate payment processing
      await _simulatePaymentProcessing(payment);

      _setLoading(false);
      
      final finalPayment = _payments.firstWhere((p) => p.id == payment.id);
      
      if (finalPayment.isCompleted) {
        return PaymentResult.success(finalPayment);
      } else {
        return PaymentResult.failure(
          finalPayment.failureReason ?? 'Payment failed',
          errorCode: 'PAYMENT_FAILED',
        );
      }
    } catch (e) {
      _setError('Payment processing failed: $e');
      _setLoading(false);
      return PaymentResult.failure('Payment processing error: $e');
    }
  }

  // Simulate payment processing
  Future<void> _simulatePaymentProcessing(Payment payment) async {
    // Update status to processing
    await _updatePaymentStatus(payment.id, PaymentStatus.processing);

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success/failure (90% success rate for demo)
    final isSuccess = kDebugMode ? (DateTime.now().millisecond % 10 != 0) : true;

    if (isSuccess) {
      await _updatePaymentStatus(
        payment.id, 
        PaymentStatus.completed,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        gatewayResponse: '{"status": "success", "transaction_id": "txn_${DateTime.now().millisecondsSinceEpoch}"}',
      );
    } else {
      await _updatePaymentStatus(
        payment.id,
        PaymentStatus.failed,
        failureReason: 'Insufficient funds',
        gatewayResponse: '{"status": "failed", "error": "Insufficient funds"}',
      );
    }
  }

  // Update payment status
  Future<void> _updatePaymentStatus(
    String paymentId,
    PaymentStatus newStatus, {
    String? transactionId,
    String? gatewayResponse,
    String? failureReason,
  }) async {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      _payments[index] = _payments[index].withStatus(
        newStatus,
        transactionId: transactionId,
        gatewayResponse: gatewayResponse,
        failureReason: failureReason,
      );
      notifyListeners();
    }
  }

  // Get payment by ID
  Payment? getPaymentById(String paymentId) {
    try {
      return _payments.firstWhere((p) => p.id == paymentId);
    } catch (e) {
      return null;
    }
  }

  // Get payments for a booking
  List<Payment> getPaymentsForBooking(String bookingId) {
    return _payments.where((p) => p.bookingId == bookingId).toList();
  }

  // Get payments by status
  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _payments.where((p) => p.status == status).toList();
  }

  // Get payment statistics
  Map<String, dynamic> getPaymentStats() {
    final totalPayments = _payments.length;
    final completedPayments = _payments.where((p) => p.isCompleted).length;
    final failedPayments = _payments.where((p) => p.isFailed).length;
    final pendingPayments = _payments.where((p) => p.isPending).length;

    final totalRevenue = _payments
        .where((p) => p.isCompleted)
        .fold<double>(0.0, (sum, p) => sum + p.amount);

    return {
      'total': totalPayments,
      'completed': completedPayments,
      'failed': failedPayments,
      'pending': pendingPayments,
      'successRate': totalPayments > 0 ? (completedPayments / totalPayments * 100).round() : 0,
      'totalRevenue': totalRevenue,
      'formattedRevenue': PaymentCurrency.usd.symbol + totalRevenue.toStringAsFixed(2),
    };
  }

  // Add saved payment method
  Future<bool> addPaymentMethod(PaymentMethodDetails paymentMethod) async {
    try {
      // Check if method already exists
      final existingIndex = _savedPaymentMethods.indexWhere(
        (method) => method.type == paymentMethod.type && 
                   method.lastFour == paymentMethod.lastFour
      );

      if (existingIndex != -1) {
        // Update existing method
        _savedPaymentMethods[existingIndex] = paymentMethod;
      } else {
        // Add new method
        _savedPaymentMethods.add(paymentMethod);
      }

      // Set as default if it's the first one or marked as default
      if (_defaultPaymentMethod == null || paymentMethod.isDefault) {
        await setDefaultPaymentMethod(paymentMethod);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add payment method: $e');
      return false;
    }
  }

  // Remove saved payment method
  Future<bool> removePaymentMethod(String paymentMethodId) async {
    try {
      _savedPaymentMethods.removeWhere((method) => 
        '${method.type.value}_${method.lastFour}' == paymentMethodId
      );

      // If removed method was default, set a new default
      if (_defaultPaymentMethod != null && 
          '${_defaultPaymentMethod!.type.value}_${_defaultPaymentMethod!.lastFour}' == paymentMethodId) {
        _defaultPaymentMethod = _savedPaymentMethods.isNotEmpty 
            ? _savedPaymentMethods.first 
            : null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove payment method: $e');
      return false;
    }
  }

  // Set default payment method
  Future<bool> setDefaultPaymentMethod(PaymentMethodDetails paymentMethod) async {
    try {
      // Remove default flag from all methods
      _savedPaymentMethods = _savedPaymentMethods.map((method) => 
        PaymentMethodDetails(
          type: method.type,
          lastFour: method.lastFour,
          expiryMonth: method.expiryMonth,
          expiryYear: method.expiryYear,
          cardholderName: method.cardholderName,
          brand: method.brand,
          isDefault: false,
          addedAt: method.addedAt,
        )
      ).toList();

      // Set new default
      final defaultIndex = _savedPaymentMethods.indexWhere(
        (method) => method.type == paymentMethod.type && 
                   method.lastFour == paymentMethod.lastFour
      );

      if (defaultIndex != -1) {
        _savedPaymentMethods[defaultIndex] = PaymentMethodDetails(
          type: paymentMethod.type,
          lastFour: paymentMethod.lastFour,
          expiryMonth: paymentMethod.expiryMonth,
          expiryYear: paymentMethod.expiryYear,
          cardholderName: paymentMethod.cardholderName,
          brand: paymentMethod.brand,
          isDefault: true,
          addedAt: paymentMethod.addedAt,
        );
        _defaultPaymentMethod = _savedPaymentMethods[defaultIndex];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to set default payment method: $e');
      return false;
    }
  }

  // Validate payment method details
  String? validatePaymentMethod(PaymentMethodDetails paymentMethod) {
    switch (paymentMethod.type) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        if (paymentMethod.lastFour == null || paymentMethod.lastFour!.length != 4) {
          return 'Invalid card number';
        }
        if (paymentMethod.expiryMonth == null || paymentMethod.expiryYear == null) {
          return 'Expiry date is required';
        }
        if (paymentMethod.cardholderName == null || paymentMethod.cardholderName!.isEmpty) {
          return 'Cardholder name is required';
        }
        break;
      case PaymentMethod.paypal:
      case PaymentMethod.applePay:
      case PaymentMethod.googlePay:
        // These would have their own validation flows
        break;
      case PaymentMethod.bankTransfer:
        // Bank transfer validation
        break;
    }
    return null;
  }

  // Calculate service price with payment processing fee
  double calculateTotalWithFee(double baseAmount, PaymentMethod method) {
    double processingFee = 0.0;
    
    switch (method) {
      case PaymentMethod.creditCard:
        processingFee = baseAmount * 0.029 + 0.30; // 2.9% + $0.30
        break;
      case PaymentMethod.debitCard:
        processingFee = baseAmount * 0.015 + 0.25; // 1.5% + $0.25
        break;
      case PaymentMethod.paypal:
        processingFee = baseAmount * 0.032 + 0.30; // 3.2% + $0.30
        break;
      case PaymentMethod.applePay:
      case PaymentMethod.googlePay:
        processingFee = baseAmount * 0.029 + 0.30; // Same as credit card
        break;
      case PaymentMethod.bankTransfer:
        processingFee = 5.0; // Flat fee
        break;
    }
    
    return baseAmount + processingFee;
  }

  // Get payment processing fee
  double getProcessingFee(double baseAmount, PaymentMethod method) {
    return calculateTotalWithFee(baseAmount, method) - baseAmount;
  }

  // Load saved payment methods (mock implementation)
  Future<void> loadSavedPaymentMethods() async {
    try {
      // In a real app, this would load from secure storage or backend
      _savedPaymentMethods = [
        PaymentMethodDetails(
          type: PaymentMethod.creditCard,
          lastFour: '1234',
          expiryMonth: '12',
          expiryYear: '25',
          cardholderName: 'John Doe',
          brand: 'Visa',
          isDefault: true,
          addedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];

      _defaultPaymentMethod = _savedPaymentMethods.isNotEmpty ? _savedPaymentMethods.first : null;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load payment methods: $e');
    }
  }

  // Load payment history
  Future<void> loadPaymentHistory() async {
    try {
      // In a real app, this would load from backend
      _payments = [
        Payment(
          id: 'payment_1',
          bookingId: 'booking_1',
          amount: 120.0,
          currency: PaymentCurrency.usd,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          processedAt: DateTime.now().subtract(const Duration(days: 7)),
          completedAt: DateTime.now().subtract(const Duration(days: 7)),
          transactionId: 'txn_123456789',
        ),
      ];

      notifyListeners();
    } catch (e) {
      _setError('Failed to load payment history: $e');
    }
  }

  // Request a refund
  Future<bool> requestRefund({
    required String paymentId,
    required double amount,
    required String reason,
  }) async {
    try {
      final payment = getPaymentById(paymentId);
      if (payment == null) {
        _setError('Payment not found');
        return false;
      }

      if (!payment.isCompleted) {
        _setError('Only completed payments can be refunded');
        return false;
      }

      if (amount > payment.amount) {
        _setError('Refund amount cannot exceed payment amount');
        return false;
      }

      // Simulate refund processing
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would process the refund through the payment gateway
      _setError('Refund processing not implemented in demo');
      return false;
    } catch (e) {
      _setError('Refund request failed: $e');
      return false;
    }
  }

  // Loading and error management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      debugPrint('PaymentProvider Error: $error');
    }
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _isLoading = false;
    _error = null;
    _payments.clear();
    _savedPaymentMethods.clear();
    _defaultPaymentMethod = null;
    notifyListeners();
  }
}
