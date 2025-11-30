// lib/models/auth_models.dart

/// Represents the different roles a user can have in the application
enum UserRole {
  /// System administrator with full access
  admin('admin'),

  /// Staff member with limited access
  staff('staff'),

  /// Regular customer
  customer('customer');

  /// String value of the role
  final String value;

  const UserRole(this.value);

  /// Creates a UserRole from a string value
  /// 
  /// Returns [UserRole.customer] if the value doesn't match any role
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value.toLowerCase(),
      orElse: () => UserRole.customer,
    );
  }

  /// Returns true if the user has admin privileges
  bool get isAdmin => this == UserRole.admin;

  /// Returns true if the user has staff privileges
  bool get isStaff => this == UserRole.staff;

  /// Returns true if the user is a regular customer
  bool get isCustomer => this == UserRole.customer;
}

/// Represents an authenticated user in the system
class AuthUser {
  /// Unique identifier for the user
  final String id;

  /// User's email address (also used as username)
  final String email;

  /// User's role in the system
  final UserRole role;

  /// User's first name
  final String firstName;

  /// User's last name
  final String? lastName;

  /// User's phone number (optional for customers)
  final String? phone;

  /// When the user account was created
  final DateTime? createdAt;

  /// User's hashed password (not stored in memory after login)
  final String? _password;

  /// Creates a new authenticated user
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    this.lastName,
    this.phone,
    this.createdAt,
    String? password,
  }) : _password = password;

  /// Creates a user from JSON data
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] is UserRole 
          ? json['role'] as UserRole 
          : UserRole.fromString(json['role'] as String? ?? 'customer'),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      password: json['password'] as String?,
    );
  }

  /// Converts the user to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.value,
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (_password != null) 'password': _password,
    };
  }

  /// Returns the user's full name
  String get fullName => lastName != null 
      ? '$firstName $lastName' 
      : firstName;

  /// Alias for fullName for backward compatibility
  String get name => fullName;

  /// Gets the user's password (for mock authentication only)
  /// In a real app, this would not be exposed
  String? get password => _password;

  /// Returns a copy of the user with updated fields
  AuthUser copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? firstName,
    String? lastName,
    String? password,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password, // Use the provided password (can be null to remove it)
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AuthUser(id: $id, email: $email, role: $role)';
}

/// Represents the result of an authentication operation
class AuthResult {
  /// The authenticated user if login was successful
  final AuthUser? user;

  /// Error message if authentication failed
  final String? error;

  /// Whether the authentication was successful
  bool get isSuccess => user != null;

  /// Creates a new authentication result
  const AuthResult({this.user, this.error});

  /// Creates a success result with the given user
  const AuthResult.success(this.user) : error = null;

  /// Creates a failure result with the given error message
  const AuthResult.failure(this.error) : user = null;

  /// Folds the AuthResult into either a failure value or success value
  T fold<T>(
    T Function(String error) onFailure,
    T Function(AuthUser user) onSuccess,
  ) {
    if (isSuccess) {
      return onSuccess(user!);
    } else {
      return onFailure(error!);
    }
  }
}