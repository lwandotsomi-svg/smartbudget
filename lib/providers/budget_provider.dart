import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/database_service.dart';

class BudgetProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBudget {
    return _budgets.fold(0, (sum, b) => sum + b.amount);
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _databaseService.getBudgets();
    } catch (e) {
      _error = 'Failed to load budgets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _databaseService.insertBudget(budget);
      _budgets.add(budget);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add budget: $e';
      notifyListeners();
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _databaseService.updateBudget(budget);
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update budget: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _databaseService.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete budget: $e';
      notifyListeners();
    }
  }

  Budget? getBudgetByCategory(String category) {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (e) {
      return null;
    }
  }
}
