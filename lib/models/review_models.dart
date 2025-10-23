class Review {
  final String id;
  final String bookingId;
  final String customerId;
  final String customerName;
  final String staffId;
  final String staffName;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.staffId,
    required this.staffName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}