import 'package:flutter/material.dart';
import '../models/upcoming_payment.dart';
import '../services/database_service.dart';

class UpcomingPaymentProvider extends ChangeNotifier {
  List<UpcomingPayment> _payments = [];
  bool _isLoading = false;

  List<UpcomingPayment> get payments => _payments;
  bool get isLoading => _isLoading;

  UpcomingPaymentProvider() {
    loadPayments();
  }

  Future<void> loadPayments() async {
    _isLoading = true;
    notifyListeners();
    _payments = await DatabaseService.getAllUpcomingPayments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPayment(UpcomingPayment payment) async {
    await DatabaseService.addUpcomingPayment(payment);
    await loadPayments();
  }

  Future<void> deletePayment(String id) async {
    await DatabaseService.deleteUpcomingPayment(id);
    await loadPayments();
  }
}
