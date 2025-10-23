// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;

class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Calculate distance between two points in meters
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // meters
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    
    final c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  /// Check if user is within radius of target location
  static Future<LocationVerificationResult> verifyLocation({
    required double targetLat,
    required double targetLon,
    double radiusMeters = 100,
  }) async {
    try {
      final position = await getCurrentLocation();
      
      if (position == null) {
        return LocationVerificationResult(
          verified: false,
          message: 'Unable to get your location',
          distance: null,
        );
      }

      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        targetLat,
        targetLon,
      );

      if (distance <= radiusMeters) {
        return LocationVerificationResult(
          verified: true,
          message: 'Location verified',
          distance: distance,
        );
      } else {
        return LocationVerificationResult(
          verified: false,
          message: 'You are ${distance.toInt()}m away from the job location',
          distance: distance,
        );
      }
    } catch (e) {
      return LocationVerificationResult(
        verified: false,
        message: e.toString(),
        distance: null,
      );
    }
  }

  static double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }

  static double sin(double radians) {
    return asin(radians);
  }
}

class LocationVerificationResult {
  final bool verified;
  final String message;
  final double? distance;

  LocationVerificationResult({
    required this.verified,
    required this.message,
    this.distance,
  });
}