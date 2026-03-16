import 'package:flutter_test/flutter_test.dart';
import 'package:smartbudget/models/transaction.dart';

void main() {
  group('Transaction Model', () {
    test('Transaction creation with all required fields', () {
      final transaction = Transaction(
        id: 'txn1',
        title: 'Grocery Shopping',
        amount: 50.0,
        date: DateTime(2024, 3, 15),
        category: 'Food',
        type: Transaction.typeExpense,
      );

      expect(transaction.id, 'txn1');
      expect(transaction.title, 'Grocery Shopping');
      expect(transaction.amount, 50.0);
      expect(transaction.date, DateTime(2024, 3, 15));
      expect(transaction.category, 'Food');
    });

    test('Transaction with negative amount', () {
      final transaction = Transaction(
        id: 'txn2',
        title: 'Refund',
        amount: -25.0,
        date: DateTime(2024, 3, 15),
        category: 'Food',
        type: Transaction.typeExpense,
      );

      expect(transaction.amount, -25.0);
    });

    test('Transaction with zero amount', () {
      final transaction = Transaction(
        id: 'txn3',
        title: 'Zero Transaction',
        amount: 0.0,
        date: DateTime(2024, 3, 15),
        category: 'Other',
        type: Transaction.typeExpense,
      );

      expect(transaction.amount, 0.0);
    });
  });
}
