import 'package:flutter/material.dart';

class SavingPlan {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String iconName; // e.g., 'home_rounded'

  SavingPlan({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.iconName = 'savings_rounded',
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  IconData get icon {
    switch (iconName) {
      case 'home_rounded':
        return Icons.home_rounded;
      case 'flight_rounded':
        return Icons.flight_rounded;
      case 'directions_car_rounded':
        return Icons.directions_car_rounded;
      case 'savings_rounded':
        return Icons.savings_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'icon_name': iconName,
      };

  factory SavingPlan.fromJson(Map<String, dynamic> json) => SavingPlan(
        id: json['id'],
        title: json['title'],
        targetAmount: (json['target_amount'] as num).toDouble(),
        currentAmount: (json['current_amount'] as num).toDouble(),
        iconName: json['icon_name'] ?? 'savings_rounded',
      );
}
