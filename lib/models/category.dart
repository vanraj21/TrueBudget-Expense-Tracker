import 'package:flutter/material.dart';
import 'transaction.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class CategoryData {
  static List<Category> get incomeCategories => [
    Category(
      id: 'salary',
      name: 'Salary',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFF00B894),
      type: TransactionType.income,
    ),
    Category(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.work,
      color: const Color(0xFF00B894),
      type: TransactionType.income,
    ),
    Category(
      id: 'investment',
      name: 'Investment',
      icon: Icons.trending_up,
      color: const Color(0xFF00B894),
      type: TransactionType.income,
    ),
    Category(
      id: 'gift',
      name: 'Gift',
      icon: Icons.card_giftcard,
      color: const Color(0xFF00B894),
      type: TransactionType.income,
    ),
    Category(
      id: 'other_income',
      name: 'Other',
      icon: Icons.more_horiz,
      color: const Color(0xFF00B894),
      type: TransactionType.income,
    ),
  ];

  static List<Category> get expenseCategories => [
    Category(
      id: 'food',
      name: 'Food',
      icon: Icons.restaurant,
      color: const Color(0xFFE74C3C),
      type: TransactionType.expense,
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car,
      color: const Color(0xFFE74C3C),
      type: TransactionType.expense,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: const Color(0xFFE74C3C),
      type: TransactionType.expense,
    ),
    Category(
      id: 'bills',
      name: 'Bills',
      icon: Icons.receipt,
      color: const Color(0xFFE74C3C),
      type: TransactionType.expense,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      color: const Color(0xFFE74C3C),
      type: TransactionType.expense,
    ),
    Category(
      id: 'health',
      name: 'Health',
      icon: Icons.local_hospital,
      color: const Color(0xFFE74C3C),
      type: TransactionType.expense,
    ),
    Category(
      id: 'education',
      name: 'Education',
      icon: Icons.school,
      color: const Color(0xFFE74C3C),
      type: TransactionType.expense,
    ),
    Category(
      id: 'other_expense',
      name: 'Other',
      icon: Icons.more_horiz,
      color: const Color(0xFFE74C3C),
      type: TransactionType.expense,
    ),
  ];

  static Category? getCategoryById(String id) {
    return [...incomeCategories, ...expenseCategories]
        .firstWhere((cat) => cat.id == id, orElse: () => expenseCategories.last);
  }
}
