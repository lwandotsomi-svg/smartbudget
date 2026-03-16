import 'package:flutter_test/flutter_test.dart';
import 'package:smartbudget/models/category.dart';

void main() {
  group('Category Model', () {
    test('Category creation with all required fields', () {
      final category = Category(
        id: 'cat1',
        name: 'Food',
        icon: 'restaurant',
      );

      expect(category.id, 'cat1');
      expect(category.name, 'Food');
      expect(category.icon, 'restaurant');
    });

    test('Multiple categories with different icons', () {
      final categories = [
        Category(id: 'c1', name: 'Food', icon: 'restaurant'),
        Category(id: 'c2', name: 'Transport', icon: 'directions_car'),
        Category(id: 'c3', name: 'Entertainment', icon: 'movie'),
        Category(id: 'c4', name: 'Health', icon: 'local_hospital'),
      ];

      expect(categories.length, 4);
      expect(categories[0].name, 'Food');
      expect(categories[3].name, 'Health');
    });

    test('Category with emoji icon', () {
      final category = Category(
        id: 'cat5',
        name: 'Shopping',
        icon: '🛍️',
      );

      expect(category.icon, '🛍️');
    });
  });
}
