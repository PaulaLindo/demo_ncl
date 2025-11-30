// lib/models/payment_model.dart
import 'package:equatable/equatable.dart';

/// Represents different payment methods
enum PaymentMethod {
  creditCard('credit_card', 'Credit Card'),
  debitCard('debit_card', 'Debit Card'),
  paypal('paypal', 'PayPal'),
  applePay('apple_pay', 'Apple Pay'),
  googlePay('google_pay', 'Google Pay'),
  bankTransfer('bank_transfer', 'Bank Transfer');

  const PaymentMethod(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Represents payment status
enum PaymentStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  cancelled('cancelled', 'Cancelled'),
  refunded('refunded', 'Refunded');

  const PaymentStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Represents payment currency
enum PaymentCurrency {
  usd('USD', 'US Dollar', '\$'),
  eur('EUR', 'Euro', '€'),
  gbp('GBP', 'British Pound', '£'),
  cad('CAD', 'Canadian Dollar', 'C\$');

  const PaymentCurrency(this.value, this.displayName, this.symbol);
  final String value;
  final String displayName;
  final String symbol;
}

/// Represents a payment transaction
class Payment extends Equatable {
  final String id;
  final String bookingId;
  final double amount;
  final PaymentCurrency currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? gatewayResponse;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.completedAt,
    this.transactionId,
    this.gatewayResponse,
    this.failureReason,
    this.metadata,
  });

  /// Creates a Payment from JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: PaymentCurrency.values.firstWhere(
        (e) => e.value == json['currency'],
        orElse: () => PaymentCurrency.usd,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.value == json['method'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      transactionId: json['transactionId'] as String?,
      gatewayResponse: json['gatewayResponse'] as String?,
      failureReason: json['failureReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts Payment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency.value,
      'method': method.value,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'gatewayResponse': gatewayResponse,
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  /// Creates a new payment for a booking
  factory Payment.create({
    required String bookingId,
    required double amount,
    required PaymentCurrency currency,
    required PaymentMethod method,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      amount: amount,
      currency: currency,
      method: method,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Get formatted amount with currency symbol
  String get formattedAmount => '${currency.symbol}${amount.toStringAsFixed(2)}';

  /// Get formatted status
  String get formattedStatus => status.displayName;

  /// Check if payment is completed successfully
  bool get isCompleted => status == PaymentStatus.completed;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Check if payment is pending or processing
  bool get isPending => status == PaymentStatus.pending || status == PaymentStatus.processing;

  /// Get payment processing duration
  Duration? get processingDuration {
    if (processedAt == null || completedAt == null) return null;
    return completedAt!.difference(processedAt!);
  }

  /// Create a copy with updated status
  Payment withStatus(PaymentStatus newStatus, {
    String? transactionId,
    String? gatewayResponse,
    String? failureReason,
  }) {
    final now = DateTime.now();
    
    return Payment(
      id: id,
      bookingId: bookingId,
      amount: amount,
      currency: currency,
      method: method,
      status: newStatus,
      createdAt: createdAt,
      processedAt: processedAt ?? (newStatus != PaymentStatus.pending ? now : null),
      completedAt: completedAt ?? (newStatus == PaymentStatus.completed ? now : null),
      transactionId: transactionId ?? this.transactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        amount,
        currency,
        method,
        status,
        createdAt,
        processedAt,
        completedAt,
        transactionId,
        gatewayResponse,
        failureReason,
        metadata,
      ];
}

/// Represents payment method details (like credit card info)
class PaymentMethodDetails extends Equatable {
  final PaymentMethod type;
  final String? lastFour;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cardholderName;
  final String? brand; // Visa, Mastercard, etc.
  final bool isDefault;
  final DateTime? addedAt;

  const PaymentMethodDetails({
    required this.type,
    this.lastFour,
    this.expiryMonth,
    this.expiryYear,
    this.cardholderName,
    this.brand,
    this.isDefault = false,
    this.addedAt,
  });

  /// Creates PaymentMethodDetails from JSON
  factory PaymentMethodDetails.fromJson(Map<String, dynamic> json) {
    return PaymentMethodDetails(
      type: PaymentMethod.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => PaymentMethod.creditCard,
      ),
      lastFour: json['lastFour'] as String?,
      expiryMonth: json['expiryMonth'] as String?,
      expiryYear: json['expiryYear'] as String?,
      cardholderName: json['cardholderName'] as String?,
      brand: json['brand'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt'] as String)
          : null,
    );
  }

  /// Converts PaymentMethodDetails to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'lastFour': lastFour,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardholderName': cardholderName,
      'brand': brand,
      'isDefault': isDefault,
      'addedAt': addedAt?.toIso8601String(),
    };
  }

  /// Get display text for the payment method
  String get displayText {
    switch (type) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        if (brand != null && lastFour != null) {
          return '$brand ****$lastFour';
        }
        return type.displayName;
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  /// Get expiry date display
  String? get expiryDisplay {
    if (expiryMonth != null && expiryYear != null) {
      return '$expiryMonth/$expiryYear';
    }
    return null;
  }

  @override
  List<Object?> get props => [
        type,
        lastFour,
        expiryMonth,
        expiryYear,
        cardholderName,
        brand,
        isDefault,
        addedAt,
      ];
}

/// Represents a payment processing result
class PaymentResult extends Equatable {
  final bool success;
  final Payment? payment;
  final String? error;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  const PaymentResult({
    required this.success,
    this.payment,
    this.error,
    this.errorCode,
    this.metadata,
  });

  /// Creates a successful payment result
  factory PaymentResult.success(Payment payment, {Map<String, dynamic>? metadata}) {
    return PaymentResult(
      success: true,
      payment: payment,
      metadata: metadata,
    );
  }

  /// Creates a failed payment result
  factory PaymentResult.failure(String error, {String? errorCode, Map<String, dynamic>? metadata}) {
    return PaymentResult(
      success: false,
      error: error,
      errorCode: errorCode,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [success, payment, error, errorCode, metadata];
}

/// Represents a refund
class Refund extends Equatable {
  final String id;
  final String paymentId;
  final double amount;
  final String reason;
  final RefundStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? transactionId;

  const Refund({
    required this.id,
    required this.paymentId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.transactionId,
  });

  @override
  List<Object?> get props => [
        id,
        paymentId,
        amount,
        reason,
        status,
        createdAt,
        processedAt,
        transactionId,
      ];
}

/// Represents refund status
enum RefundStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed');

  const RefundStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}
