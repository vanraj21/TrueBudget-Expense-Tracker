import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _balance = 0.0;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _balance;

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    _transactions = await DatabaseService.getAllTransactions();
    _totalIncome = await DatabaseService.getTotalIncome();
    _totalExpense = await DatabaseService.getTotalExpense();
    _balance = await DatabaseService.getBalance();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      print('Adding transaction: ${transaction.title}');
      await DatabaseService.addTransaction(transaction);
      print('Transaction added successfully');
      await loadTransactions();
      print('Transactions reloaded');
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _isLoading = true;
    notifyListeners();
    
    await DatabaseService.deleteTransaction(id);
    await loadTransactions();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    _isLoading = true;
    notifyListeners();
    
    await DatabaseService.updateTransaction(transaction);
    await loadTransactions();
    
    _isLoading = false;
    notifyListeners();
  }

  List<Transaction> getTransactionsByMonth(DateTime month) {
    return _transactions.where((t) => 
      t.date.year == month.year && t.date.month == month.month
    ).toList();
  }
}
