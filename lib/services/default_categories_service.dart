import '../models/category.dart';
import 'database_service.dart';

class DefaultCategoriesService {
  static final DefaultCategoriesService _instance =
      DefaultCategoriesService._internal();

  factory DefaultCategoriesService() => _instance;

  DefaultCategoriesService._internal();

  // Default expense categories
  static const List<Map<String, String>> defaultExpenseCategories = [
    {'name': 'Food & Dining', 'icon': '🍔'},
    {'name': 'Transport', 'icon': '🚗'},
    {'name': 'Shopping', 'icon': '🛍️'},
    {'name': 'Entertainment', 'icon': '🎬'},
    {'name': 'Utilities', 'icon': '💡'},
    {'name': 'Healthcare', 'icon': '🏥'},
    {'name': 'Education', 'icon': '📚'},
    {'name': 'Insurance', 'icon': '🛡️'},
    {'name': 'Personal Care', 'icon': '💄'},
    {'name': 'Subscriptions', 'icon': '📱'},
    {'name': 'Home & Rent', 'icon': '🏠'},
    {'name': 'Other Expense', 'icon': '📌'},
  ];

  // Default income categories
  static const List<Map<String, String>> defaultIncomeCategories = [
    {'name': 'Salary', 'icon': '💼'},
    {'name': 'Bonus', 'icon': '🎁'},
    {'name': 'Freelance', 'icon': '💻'},
    {'name': 'Investment', 'icon': '📈'},
    {'name': 'Gift', 'icon': '🎉'},
    {'name': 'Refund', 'icon': '↩️'},
    {'name': 'Other Income', 'icon': '💰'},
  ];

  /// Initialize default categories on first app launch
  Future<void> initializeDefaultCategories() async {
    final db = await DatabaseService().database;

    // Check if already initialized
    final existing = await db.query('categories');
    if (existing.isNotEmpty) {
      return; // Already initialized
    }

    try {
      // Insert expense categories
      for (final cat in defaultExpenseCategories) {
        final category = Category(
          id: cat['name']!.toLowerCase().replaceAll(' ', '_'),
          name: cat['name']!,
          icon: cat['icon'],
        );
        await db.insert('categories', category.toMap());
      }

      // Insert income categories
      for (final cat in defaultIncomeCategories) {
        final category = Category(
          id: 'income_${cat['name']!.toLowerCase().replaceAll(' ', '_')}',
          name: cat['name']!,
          icon: cat['icon'],
        );
        await db.insert('categories', category.toMap());
      }
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }

  /// Get all expense categories
  Future<List<Category>> getExpenseCategories() async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      'categories',
      where: 'id NOT LIKE ?',
      whereArgs: ['income_%'],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  /// Get all income categories
  Future<List<Category>> getIncomeCategories() async {
    final db = await DatabaseService().database;
    final maps = await db.query(
      'categories',
      where: 'id LIKE ?',
      whereArgs: ['income_%'],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }
}
