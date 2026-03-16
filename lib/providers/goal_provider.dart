import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class GoalProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get goalCount => _goals.length;
  int get activeGoalCount => activeGoals.length;

  double get totalGoalAmount =>
      _goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
  double get totalCurrentAmount =>
      _goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);
  double get overallProgress {
    if (totalGoalAmount <= 0) return 0;
    return (totalCurrentAmount / totalGoalAmount) * 100;
  }

  Goal? getGoalById(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new goal
  Future<void> createGoal({
    required String title,
    required double targetAmount,
    required DateTime targetDate,
    required String description,
  }) async {
    try {
      if (title.isEmpty) {
        _error = 'Goal title cannot be empty';
        notifyListeners();
        return;
      }
      if (targetAmount <= 0) {
        _error = 'Target amount must be greater than 0';
        notifyListeners();
        return;
      }
      if (targetDate.isBefore(DateTime.now())) {
        _error = 'Target date must be in the future';
        notifyListeners();
        return;
      }

      final goal = Goal(
        id: const Uuid().v4(),
        title: title,
        targetAmount: targetAmount,
        currentAmount: 0,
        createdDate: DateTime.now(),
        targetDate: targetDate,
        description: description,
        isActive: true,
      );

      _goals.add(goal);
      
      // Schedule daily notifications for this goal
      await _notificationService.scheduleDailyNotifications(goal);
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create goal: $e';
      notifyListeners();
    }
  }

  /// Update goal progress
  Future<void> updateGoalProgress({
    required String goalId,
    required double newAmount,
  }) async {
    try {
      if (newAmount < 0) {
        _error = 'Amount cannot be negative';
        notifyListeners();
        return;
      }

      final goal = getGoalById(goalId);
      if (goal != null) {
        final updatedGoal = goal.copyWith(currentAmount: newAmount);
        final index = _goals.indexWhere((g) => g.id == goalId);
        if (index != -1) {
          _goals[index] = updatedGoal;
          _error = null;
          notifyListeners();

          // Send notification if goal is reached
          if (updatedGoal.isGoalReached && !goal.isGoalReached) {
            await _notificationService.sendImmediateNotification(
              title: '🎉 Goal Reached!',
              body: 'Congratulations! You\'ve reached your goal "${updatedGoal.title}"!',
            );
          }
        }
      }
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  /// Add amount to goal progress
  Future<void> addToGoal({
    required String goalId,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        _error = 'Amount must be greater than 0';
        notifyListeners();
        return;
      }

      final goal = getGoalById(goalId);
      if (goal != null) {
        final newAmount = goal.currentAmount + amount;
        await updateGoalProgress(goalId: goalId, newAmount: newAmount);
      }
    } catch (e) {
      _error = 'Failed to add to goal: $e';
      notifyListeners();
    }
  }

  /// Deactivate a goal
  Future<void> deactivateGoal(String goalId) async {
    try {
      final goal = getGoalById(goalId);
      if (goal != null) {
        final updatedGoal = goal.copyWith(isActive: false);
        final index = _goals.indexWhere((g) => g.id == goalId);
        if (index != -1) {
          _goals[index] = updatedGoal;
          
          // Cancel notifications for this goal
          await _notificationService.cancelNotifications(goalId);
          
          _error = null;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to deactivate goal: $e';
      notifyListeners();
    }
  }

  /// Reactivate a goal
  Future<void> reactivateGoal(String goalId) async {
    try {
      final goal = getGoalById(goalId);
      if (goal != null) {
        final updatedGoal = goal.copyWith(isActive: true);
        final index = _goals.indexWhere((g) => g.id == goalId);
        if (index != -1) {
          _goals[index] = updatedGoal;
          
          // Schedule notifications again
          await _notificationService.scheduleDailyNotifications(updatedGoal);
          
          _error = null;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to reactivate goal: $e';
      notifyListeners();
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      _goals.removeWhere((g) => g.id == goalId);
      
      // Cancel notifications
      await _notificationService.cancelNotifications(goalId);
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete goal: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
