import 'package:flutter_test/flutter_test.dart';
import 'package:smartbudget/models/budget.dart';

void main() {
  group('Budget Model', () {
    test('Budget creation with all required fields', () {
      final budget = Budget(
        id: 'budget1',
        name: 'Monthly Groceries',
        amount: 500.0,
        category: 'Food',
      );

      expect(budget.id, 'budget1');
      expect(budget.name, 'Monthly Groceries');
      expect(budget.amount, 500.0);
      expect(budget.category, 'Food');
    });

    test('Budget with different categories', () {
      final foodBudget = Budget(
        id: 'b1',
        name: 'Food Budget',
        amount: 300.0,
        category: 'Food',
      );

      final transportBudget = Budget(
        id: 'b2',
        name: 'Transport Budget',
        amount: 200.0,
        category: 'Transport',
      );

      expect(foodBudget.category, 'Food');
      expect(transportBudget.category, 'Transport');
    });

    test('Budget with large amount', () {
      final budget = Budget(
        id: 'budget3',
        name: 'Annual Budget',
        amount: 10000.0,
        category: 'Life',
      );

      expect(budget.amount, 10000.0);
    });
  });
}
