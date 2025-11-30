// lib/models/user_model.dart
import 'package:equatable/equatable.dart';

/// Represents a user in the system, which can be either a customer or staff member.
class User extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final bool isStaff;
  final bool isAdmin;

  const User({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.isStaff = false,
    this.isAdmin = false,
  }) : assert(
          !isAdmin || (isAdmin && isStaff),
          'Admin must also be a staff member',
        );

  /// Creates a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isStaff: json['isStaff'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  /// Converts the user to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'isStaff': isStaff,
      'isAdmin': isAdmin,
    };
  }

  /// Creates a copy of this user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isStaff,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isStaff: isStaff ?? this.isStaff,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, isStaff, isAdmin];

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, '
      'isStaff: $isStaff, isAdmin: $isAdmin)';
}