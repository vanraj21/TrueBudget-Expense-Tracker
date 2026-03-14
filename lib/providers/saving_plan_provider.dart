import 'package:flutter/material.dart';
import '../models/saving_plan.dart';
import '../services/database_service.dart';

class SavingPlanProvider extends ChangeNotifier {
  List<SavingPlan> _plans = [];
  bool _isLoading = false;

  List<SavingPlan> get plans => _plans;
  bool get isLoading => _isLoading;

  SavingPlanProvider() {
    loadPlans();
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();
    _plans = await DatabaseService.getAllSavingPlans();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPlan(SavingPlan plan) async {
    await DatabaseService.addSavingPlan(plan);
    await loadPlans();
  }

  Future<void> updatePlan(SavingPlan plan) async {
    await DatabaseService.updateSavingPlan(plan);
    await loadPlans();
  }

  Future<void> deletePlan(String id) async {
    await DatabaseService.deleteSavingPlan(id);
    await loadPlans();
  }
}
