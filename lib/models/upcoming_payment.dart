import 'package:flutter/material.dart';

class UpcomingPayment {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final IconData icon;
  final Color color;

  UpcomingPayment({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.icon,
    required this.color,
  });

  String get dueTime {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    } else {
      return 'Due now';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'due_date': dueDate.toIso8601String(),
        'icon_name': _iconToName(icon),
        'color_value': color.toARGB32(),
      };

  static String _iconToName(IconData icon) {
    // Map common icons to string names
    if (icon.codePoint == Icons.movie_rounded.codePoint) return 'movie_rounded';
    if (icon.codePoint == Icons.receipt_long_rounded.codePoint) return 'receipt_long_rounded';
    if (icon.codePoint == Icons.music_note_rounded.codePoint) return 'music_note_rounded';
    if (icon.codePoint == Icons.electric_bolt_rounded.codePoint) return 'electric_bolt_rounded';
    return 'receipt_long_rounded';
  }

  static IconData _nameToIcon(String name) {
    switch (name) {
      case 'movie_rounded':
        return Icons.movie_rounded;
      case 'receipt_long_rounded':
        return Icons.receipt_long_rounded;
      case 'music_note_rounded':
        return Icons.music_note_rounded;
      case 'electric_bolt_rounded':
        return Icons.electric_bolt_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  factory UpcomingPayment.fromJson(Map<String, dynamic> json) => UpcomingPayment(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        dueDate: DateTime.parse(json['due_date']),
        icon: _nameToIcon(json['icon_name'] ?? 'receipt_long_rounded'),
        color: Color(json['color_value'] ?? 0xFF00E676),
      );
}
