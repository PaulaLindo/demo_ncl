// lib/models/navigation_item.dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Represents an item in the app's navigation
class NavigationItem extends Equatable {
  final String label;
  final IconData icon;
  final String route;
  final int badgeCount;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount = 0,
  });

  /// Creates a NavigationItem from JSON
  factory NavigationItem.fromJson(Map<String, dynamic> json) {
    return NavigationItem(
      label: json['label'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      ),
      route: json['route'] as String,
      badgeCount: (json['badgeCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'iconCodePoint': icon.codePoint,
      'route': route,
      if (badgeCount > 0) 'badgeCount': badgeCount,
    };
  }

  /// Creates a copy with updated fields
  NavigationItem copyWith({
    String? label,
    IconData? icon,
    String? route,
    int? badgeCount,
  }) {
    return NavigationItem(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }

  @override
  List<Object> get props => [label, icon.codePoint, route, badgeCount];

  @override
  String toString() => 'NavigationItem(label: $label, route: $route)';
}