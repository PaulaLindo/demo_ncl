// lib/data/mocks/gig_mock_data.dart
import '../../models/gig_model.dart';

class GigMockData {
  static Gig getGigById(String gigId) {
    final gigData = _getGigData(gigId);
    return Gig.fromMap(gigData);
  }

  static Map<String, dynamic> _getGigData(String gigId) {
    switch (gigId) {
      case 'gig_1':
        return {
          'id': 'gig_1',
          'title': 'Deep Cleaning - Downtown Office',
          'client': 'ABC Corporation',
          'serviceType': 'Commercial Deep Cleaning',
          'address': '123 Main St, Downtown Cape Town',
          'distance': '2.5 km from your location',
          'date': '2023-12-03',
          'time': '09:00 AM',
          'duration': '4 hours',
          'baseRate': '\$120.00',
          'transport': '\$15.00',
          'totalPay': '\$135.00',
          'requirements': ['Gloves', 'Mask', 'ID Badge'],
          'status': 'confirmed',
          'latitude': -33.9249,
          'longitude': 18.4241,
          'location': '123 Main St, Cape Town',
        };
      case 'gig_2':
        return {
          'id': 'gig_2',
          'title': 'Regular Cleaning - Suburban Home',
          'client': 'Smith Family',
          'serviceType': 'Residential Cleaning',
          'address': '45 Oak Avenue, Suburbia',
          'distance': '5.2 km from your location',
          'date': '2023-12-04',
          'time': '01:30 PM',
          'duration': '2.5 hours',
          'baseRate': '\$85.00',
          'transport': '\$10.00',
          'totalPay': '\$95.00',
          'requirements': ['Gloves', 'Apron'],
          'status': 'confirmed',
          'latitude': -33.9349,
          'longitude': 18.4341,
          'location': '45 Oak Avenue, Suburbia',
        };
      default:
        return {
          'id': gigId,
          'title': 'Kitchen Cleaning - Restaurant',
          'client': 'Italian Restaurant',
          'serviceType': 'Commercial Kitchen Cleaning',
          'address': '789 Food Court, City Center',
          'distance': '3.1 km from your location',
          'date': '2023-12-05',
          'time': '06:00 AM',
          'duration': '3 hours',
          'baseRate': '\$150.00',
          'transport': '\$20.00',
          'totalPay': '\$170.00',
          'requirements': ['Hair Net', 'Non-slip Shoes', 'Sanitizer'],
          'status': 'pending',
          'latitude': -33.9149,
          'longitude': 18.4141,
          'location': '789 Food Court, City Center',
        };
    }
  }
}