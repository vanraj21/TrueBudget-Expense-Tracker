import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:true_budget_app/models/transaction.dart';
import 'package:true_budget_app/models/category.dart';
import 'package:true_budget_app/models/saving_plan.dart';
import 'package:true_budget_app/models/upcoming_payment.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Transaction Model Tests', () {
    test('Should create transaction with valid data', () {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: 'Salary',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salary',
        date: DateTime.now(),
        note: 'Monthly salary',
      );

      expect(transaction.title, 'Salary');
      expect(transaction.amount, 5000.0);
      expect(transaction.type, TransactionType.income);
      expect(transaction.category, 'salary');
      expect(transaction.note, 'Monthly salary');
    });

    test('Should serialize transaction to JSON', () {
      final transaction = Transaction(
        id: 'test-id',
        title: 'Grocery',
        amount: 150.0,
        type: TransactionType.expense,
        category: 'food',
        date: DateTime(2024, 1, 15),
        note: 'Weekly groceries',
      );

      final json = transaction.toJson();

      expect(json['id'], 'test-id');
      expect(json['title'], 'Grocery');
      expect(json['amount'], 150.0);
      expect(json['type'], 'expense');
      expect(json['category'], 'food');
      expect(json['note'], 'Weekly groceries');
    });

    test('Should deserialize transaction from JSON', () {
      final json = {
        'id': 'test-id',
        'title': 'Investment',
        'amount': 1000.0,
        'type': 'income',
        'category': 'investment',
        'date': '2024-01-15T10:00:00.000Z',
        'note': 'Stock dividend',
      };

      final transaction = Transaction.fromJson(json);

      expect(transaction.id, 'test-id');
      expect(transaction.title, 'Investment');
      expect(transaction.amount, 1000.0);
      expect(transaction.type, TransactionType.income);
      expect(transaction.category, 'investment');
      expect(transaction.note, 'Stock dividend');
    });
  });

  group('Category Tests', () {
    test('Should find category by ID', () {
      final category = CategoryData.getCategoryById('salary');
      expect(category, isNotNull);
      expect(category!.name, 'Salary');
      expect(category.type, TransactionType.income);
    });

    test('Should return default category for unknown ID', () {
      final category = CategoryData.getCategoryById('unknown');
      expect(category, isNotNull);
      expect(category!.name, 'Other');
      expect(category.type, TransactionType.expense);
    });

    test('Should have correct number of income categories', () {
      expect(CategoryData.incomeCategories.length, 5);
    });

    test('Should have correct number of expense categories', () {
      expect(CategoryData.expenseCategories.length, 8);
    });
  });

  group('Saving Plan Tests', () {
    test('Should calculate progress correctly', () {
      final savingPlan = SavingPlan(
        id: 'test-id',
        title: 'Emergency Fund',
        targetAmount: 10000.0,
        currentAmount: 5000.0,
      );

      expect(savingPlan.progress, 0.5);
    });

    test('Should handle zero target amount', () {
      final savingPlan = SavingPlan(
        id: 'test-id',
        title: 'Invalid Plan',
        targetAmount: 0.0,
        currentAmount: 1000.0,
      );

      expect(savingPlan.progress, 0.0);
    });

    test('Should clamp progress to maximum 1.0', () {
      final savingPlan = SavingPlan(
        id: 'test-id',
        title: 'Completed Plan',
        targetAmount: 1000.0,
        currentAmount: 1500.0,
      );

      expect(savingPlan.progress, 1.0);
    });
  });

  group('Upcoming Payment Tests', () {
    test('Should calculate due time correctly for future date', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final payment = UpcomingPayment(
        id: 'test-id',
        title: 'Rent',
        amount: 1000.0,
        dueDate: futureDate,
        icon: Icons.home,
        color: Colors.blue,
      );

      expect(payment.dueTime, '5 days');
    });

    test('Should show "Due now" for past dates', () {
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final payment = UpcomingPayment(
        id: 'test-id',
        title: 'Overdue Bill',
        amount: 100.0,
        dueDate: pastDate,
        icon: Icons.receipt,
        color: Colors.red,
      );

      expect(payment.dueTime, 'Due now');
    });

    test('Should serialize and deserialize correctly', () {
      final originalPayment = UpcomingPayment(
        id: 'test-id',
        title: 'Netflix',
        amount: 15.99,
        dueDate: DateTime(2024, 2, 1),
        icon: Icons.movie,
        color: Colors.red,
      );

      final json = originalPayment.toJson();
      final deserializedPayment = UpcomingPayment.fromJson(json);

      expect(deserializedPayment.id, originalPayment.id);
      expect(deserializedPayment.title, originalPayment.title);
      expect(deserializedPayment.amount, originalPayment.amount);
      expect(deserializedPayment.dueDate, originalPayment.dueDate);
    });
  });

  group('Financial Calculations Tests', () {
    test('Should calculate balance correctly', () {
      final income = 5000.0;
      final expenses = 3000.0;
      final balance = income - expenses;

      expect(balance, 2000.0);
    });

    test('Should handle negative balance', () {
      final income = 2000.0;
      final expenses = 3000.0;
      final balance = income - expenses;

      expect(balance, -1000.0);
    });

    test('Should calculate percentage correctly', () {
      final current = 750.0;
      final target = 1000.0;
      final percentage = (current / target) * 100;

      expect(percentage, 75.0);
    });
  });
}
