// models/transport.dart
class TransportBooking {
  final String id;
  final DateTime bookingTime;
  final String pickupLocation;
  final String destination;
  final String status; // "scheduled", "in_progress", "completed"
  final String? driverName;
  final String? vehicleDetails;
  final double? estimatedFare;
  // Add other relevant fields

  const TransportBooking({
    required this.id,
    required this.bookingTime,
    required this.pickupLocation,
    required this.destination,
    required this.status,
    this.driverName,
    this.vehicleDetails,
    this.estimatedFare,
  });
}