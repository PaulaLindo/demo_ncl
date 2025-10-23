// lib/utils/validators.dart
class Validators {
  /// Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Phone number validation (South African format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and special characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check for valid SA phone number (starts with 0 or +27)
    final phoneRegex = RegExp(r'^(0|\+27)[0-9]{9}$');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid South African phone number';
    }
    
    return null;
  }

  /// Required field validation
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Minimum length validation
  static String? minLength(String? value, int length, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < length) {
      return '$fieldName must be at least $length characters';
    }
    
    return null;
  }

  /// Maximum length validation
  static String? maxLength(String? value, int length, [String fieldName = 'This field']) {
    if (value != null && value.length > length) {
      return '$fieldName must not exceed $length characters';
    }
    return null;
  }

  /// PIN validation (4 digits)
  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    
    if (value.length != 4) {
      return 'PIN must be exactly 4 digits';
    }
    
    if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
      return 'PIN must contain only numbers';
    }
    
    return null;
  }

  /// Password strength validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    // Optional: Add stronger validation
    // if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
    //   return 'Password must contain at least one uppercase letter';
    // }
    
    return null;
  }

  /// Staff ID validation
  static String? staffId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Staff ID is required';
    }
    
    if (value.length < 6) {
      return 'Staff ID must be at least 6 characters';
    }
    
    return null;
  }

  /// Address validation
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    
    return null;
  }

  /// Date validation (not in the past)
  static String? futureDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(value.year, value.month, value.day);
    
    if (selectedDate.isBefore(today)) {
      return 'Date cannot be in the past';
    }
    
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}

