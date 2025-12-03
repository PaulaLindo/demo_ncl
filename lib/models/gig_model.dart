// lib/models/gig_model.dart
class Gig {
  final String id;
  final String title;
  final String client;
  final String serviceType;
  final String address;
  final String distance;
  final String date;
  final String time;
  final String duration;
  final String baseRate;
  final String transport;
  final String totalPay;
  final List<String> requirements;
  final String status;
  final double latitude;
  final double longitude;
  final String location;

  Gig({
    required this.id,
    required this.title,
    required this.client,
    required this.serviceType,
    required this.address,
    required this.distance,
    required this.date,
    required this.time,
    required this.duration,
    required this.baseRate,
    required this.transport,
    required this.totalPay,
    required this.requirements,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.location,
  });

  factory Gig.fromMap(Map<String, dynamic> map) {
    return Gig(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      client: map['client'] ?? '',
      serviceType: map['serviceType'] ?? '',
      address: map['address'] ?? '',
      distance: map['distance'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      duration: map['duration'] ?? '',
      baseRate: map['baseRate'] ?? '',
      transport: map['transport'] ?? '',
      totalPay: map['totalPay'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      status: map['status'] ?? 'pending',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
    );
  }
}