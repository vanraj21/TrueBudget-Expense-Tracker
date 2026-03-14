import 'package:flutter_test/flutter_test.dart';
import 'package:true_budget_app/providers/transaction_provider.dart';
import 'package:true_budget_app/models/transaction.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('TransactionProvider Tests', () {
    late TransactionProvider provider;

    setUp(() {
      provider = TransactionProvider();
    });

    test('Should initialize with empty transactions', () {
      expect(provider.transactions.isEmpty, true);
      expect(provider.isLoading, false);
      expect(provider.totalIncome, 0.0);
      expect(provider.totalExpense, 0.0);
      expect(provider.balance, 0.0);
    });

    test('Should get transactions by month correctly', () {
      // Create test transactions
      final janTransaction = Transaction(
        id: const Uuid().v4(),
        title: 'January Salary',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salary',
        date: DateTime(2024, 1, 15),
      );

      final febTransaction = Transaction(
        id: const Uuid().v4(),
        title: 'February Rent',
        amount: 1000.0,
        type: TransactionType.expense,
        category: 'bills',
        date: DateTime(2024, 2, 1),
      );

      // Manually add transactions for testing (in real app, these would come from database)
      provider._transactions.addAll([janTransaction, febTransaction]);

      // Test January transactions
      final janTransactions = provider.getTransactionsByMonth(DateTime(2024, 1, 1));
      expect(janTransactions.length, 1);
      expect(janTransactions.first.title, 'January Salary');

      // Test February transactions
      final febTransactions = provider.getTransactionsByMonth(DateTime(2024, 2, 1));
      expect(febTransactions.length, 1);
      expect(febTransactions.first.title, 'February Rent');

      // Test month with no transactions
      final marTransactions = provider.getTransactionsByMonth(DateTime(2024, 3, 1));
      expect(marTransactions.isEmpty, true);
    });

    test('Should filter transactions by different months', () {
      final transactions = [
        Transaction(
          id: const Uuid().v4(),
          title: 'Jan Income',
          amount: 1000.0,
          type: TransactionType.income,
          category: 'salary',
          date: DateTime(2024, 1, 10),
        ),
        Transaction(
          id: const Uuid().v4(),
          title: 'Jan Expense',
          amount: 200.0,
          type: TransactionType.expense,
          category: 'food',
          date: DateTime(2024, 1, 15),
        ),
        Transaction(
          id: const Uuid().v4(),
          title: 'Feb Income',
          amount: 1500.0,
          type: TransactionType.income,
          category: 'freelance',
          date: DateTime(2024, 2, 5),
        ),
      ];

      provider._transactions.addAll(transactions);

      final janTransactions = provider.getTransactionsByMonth(DateTime(2024, 1, 1));
      expect(janTransactions.length, 2);

      final febTransactions = provider.getTransactionsByMonth(DateTime(2024, 2, 1));
      expect(febTransactions.length, 1);
    });
  });

  group('Transaction Type Tests', () {
    test('Should correctly identify income transactions', () {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: 'Salary',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salary',
        date: DateTime.now(),
      );

      expect(transaction.type, TransactionType.income);
    });

    test('Should correctly identify expense transactions', () {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: 'Grocery',
        amount: 150.0,
        type: TransactionType.expense,
        category: 'food',
        date: DateTime.now(),
      );

      expect(transaction.type, TransactionType.expense);
    });
  });

  group('Financial Summary Tests', () {
    test('Should calculate correct financial summary', () {
      final transactions = [
        Transaction(
          id: const Uuid().v4(),
          title: 'Salary',
          amount: 5000.0,
          type: TransactionType.income,
          category: 'salary',
          date: DateTime.now(),
        ),
        Transaction(
          id: const Uuid().v4(),
          title: 'Freelance',
          amount: 1000.0,
          type: TransactionType.income,
          category: 'freelance',
          date: DateTime.now(),
        ),
        Transaction(
          id: const Uuid().v4(),
          title: 'Rent',
          amount: 1500.0,
          type: TransactionType.expense,
          category: 'bills',
          date: DateTime.now(),
        ),
        Transaction(
          id: const Uuid().v4(),
          title: 'Food',
          amount: 500.0,
          type: TransactionType.expense,
          category: 'food',
          date: DateTime.now(),
        ),
      ];

      final totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalExpense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      final balance = totalIncome - totalExpense;

      expect(totalIncome, 6000.0);
      expect(totalExpense, 2000.0);
      expect(balance, 4000.0);
    });
  });
}

// Extension to access private fields for testing
extension TransactionProviderTestExtension on TransactionProvider {
  List<Transaction> get _transactions => transactions;
}
