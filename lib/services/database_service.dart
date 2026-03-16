import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/category.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smartbudget.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
      singleInstance: true, // Ensure single database connection
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');

    // Enable WAL (Write-Ahead Logging) for better performance and concurrency
    await db.execute('PRAGMA journal_mode = WAL');

    // Optimize cache size for better RAM usage (-64000 = 64MB)
    await db.execute('PRAGMA cache_size = -64000');

    // Optimize synchronous mode for offline use (NORMAL is safer than FULL)
    await db.execute('PRAGMA synchronous = NORMAL');

    // Enable memory-mapped I/O for better read performance
    await db.execute('PRAGMA query_only = false');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migration from v1 to v2
    if (oldVersion < 2) {
      // Add new columns to transactions table
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN type TEXT DEFAULT "expense"');
      await db.execute('ALTER TABLE transactions ADD COLUMN notes TEXT');
      await db.execute(
          'ALTER TABLE transactions ADD COLUMN isRecurring INTEGER DEFAULT 0');
      await db
          .execute('ALTER TABLE transactions ADD COLUMN recurringPattern TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories first (referenced by transactions and budgets)
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense',
        notes TEXT,
        isRecurring INTEGER DEFAULT 0,
        recurringPattern TEXT,
        FOREIGN KEY(category) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        category TEXT NOT NULL,
        FOREIGN KEY(category) REFERENCES categories(id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(date DESC)');
    await db.execute(
        'CREATE INDEX idx_transactions_category ON transactions(category)');
    await db.execute('CREATE INDEX idx_budgets_category ON budgets(category)');
  }

  // Transaction operations
  Future<void> insertTransaction(Transaction transaction) async {
    try {
      _validateTransaction(transaction);
      final db = await database;
      await db.insert(
        'transactions',
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final db = await database;
      final maps = await db.query('transactions', orderBy: 'date DESC');
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      _validateTransaction(transaction);
      final db = await database;
      await db.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      if (id.isEmpty) throw Exception('Transaction ID cannot be empty');
      final db = await database;
      await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Budget operations
  Future<void> insertBudget(Budget budget) async {
    try {
      _validateBudget(budget);
      final db = await database;
      await db.insert(
        'budgets',
        budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert budget: $e');
    }
  }

  Future<List<Budget>> getBudgets() async {
    try {
      final db = await database;
      final maps = await db.query('budgets');
      return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to fetch budgets: $e');
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      _validateBudget(budget);
      final db = await database;
      await db.update(
        'budgets',
        budget.toMap(),
        where: 'id = ?',
        whereArgs: [budget.id],
      );
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      if (id.isEmpty) throw Exception('Budget ID cannot be empty');
      final db = await database;
      await db.delete(
        'budgets',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }

  // Category operations
  Future<void> insertCategory(Category category) async {
    try {
      _validateCategory(category);
      final db = await database;
      await db.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert category: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final db = await database;
      final maps = await db.query('categories');
      return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      _validateCategory(category);
      final db = await database;
      await db.update(
        'categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      if (id.isEmpty) throw Exception('Category ID cannot be empty');
      final db = await database;
      await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Utility methods for data management
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('transactions');
        await txn.delete('budgets');
        await txn.delete('categories');
      });
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  Future<void> deleteAllTransactions() async {
    try {
      final db = await database;
      await db.delete('transactions');
    } catch (e) {
      throw Exception('Failed to delete transactions: $e');
    }
  }

  Future<void> deleteAllBudgets() async {
    try {
      final db = await database;
      await db.delete('budgets');
    } catch (e) {
      throw Exception('Failed to delete budgets: $e');
    }
  }

  // Validation methods
  void _validateTransaction(Transaction transaction) {
    if (transaction.id.isEmpty) {
      throw Exception('Transaction ID cannot be empty');
    }
    if (transaction.title.isEmpty) {
      throw Exception('Transaction title cannot be empty');
    }
    if (transaction.amount <= 0) {
      throw Exception('Transaction amount must be greater than 0');
    }
    if (transaction.category.isEmpty) {
      throw Exception('Transaction category cannot be empty');
    }
  }

  void _validateBudget(Budget budget) {
    if (budget.id.isEmpty) throw Exception('Budget ID cannot be empty');
    if (budget.name.isEmpty) throw Exception('Budget name cannot be empty');
    if (budget.amount <= 0) {
      throw Exception('Budget amount must be greater than 0');
    }
    if (budget.category.isEmpty) {
      throw Exception('Budget category cannot be empty');
    }
  }

  void _validateCategory(Category category) {
    if (category.id.isEmpty) throw Exception('Category ID cannot be empty');
    if (category.name.isEmpty) throw Exception('Category name cannot be empty');
    // icon is optional, so no validation needed for it
  }

  Future<void> close() async {
    try {
      final db = _database;
      if (db != null) {
        await db.close();
      }
    } catch (e) {
      throw Exception('Failed to close database: $e');
    }
  }
}
