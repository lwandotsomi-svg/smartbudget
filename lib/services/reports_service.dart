import '../models/transaction.dart';
import 'database_service.dart';

class ReportsService {
  static final ReportsService _instance = ReportsService._internal();

  factory ReportsService() => _instance;

  ReportsService._internal();

  /// Get transaction data for pie chart (by category)
  Future<Map<String, double>> getExpenseByCategoryChart() async {
    final transactions = await DatabaseService().getTransactions();
    final expenses =
        transactions.where((t) => t.type == Transaction.typeExpense);

    final Map<String, double> categoryTotals = {};
    for (final tx in expenses) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    return categoryTotals;
  }

  /// Get transaction data for pie chart (by category) - income
  Future<Map<String, double>> getIncomeByCategoryChart() async {
    final transactions = await DatabaseService().getTransactions();
    final income = transactions.where((t) => t.type == Transaction.typeIncome);

    final Map<String, double> categoryTotals = {};
    for (final tx in income) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    return categoryTotals;
  }

  /// Get daily spending data for line chart
  Future<Map<DateTime, double>> getDailySpendingChart({int days = 30}) async {
    final transactions = await DatabaseService().getTransactions();
    final startDate = DateTime.now().subtract(Duration(days: days));

    final filtered = transactions.where(
        (t) => t.date.isAfter(startDate) && t.type == Transaction.typeExpense);

    final Map<DateTime, double> dailyTotals = {};
    for (final tx in filtered) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + tx.amount;
    }

    return dailyTotals;
  }

  /// Get monthly spending data for bar chart
  Future<Map<String, double>> getMonthlySpendingChart({int months = 12}) async {
    final transactions = await DatabaseService().getTransactions();
    final startDate = DateTime.now().subtract(Duration(days: 30 * months));

    final filtered = transactions.where(
        (t) => t.date.isAfter(startDate) && t.type == Transaction.typeExpense);

    final Map<String, double> monthlyTotals = {};
    for (final tx in filtered) {
      final monthKey =
          '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + tx.amount;
    }

    return monthlyTotals;
  }

  /// Get income vs expense comparison
  Future<Map<String, double>> getIncomeExpenseComparison(
      {int months = 12}) async {
    final transactions = await DatabaseService().getTransactions();
    final startDate = DateTime.now().subtract(Duration(days: 30 * months));

    final filtered = transactions.where((t) => t.date.isAfter(startDate));

    double totalIncome = 0;
    double totalExpense = 0;

    for (final tx in filtered) {
      if (tx.type == Transaction.typeIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    return {
      'Income': totalIncome,
      'Expense': totalExpense,
      'Net': totalIncome - totalExpense,
    };
  }

  /// Get summary statistics
  Future<Map<String, dynamic>> getSummaryStats() async {
    final transactions = await DatabaseService().getTransactions();

    if (transactions.isEmpty) {
      return {
        'totalTransactions': 0,
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'balance': 0.0,
        'avgTransaction': 0.0,
        'highestExpense': 0.0,
      };
    }

    double totalIncome = 0;
    double totalExpense = 0;
    double highestExpense = 0;

    for (final tx in transactions) {
      if (tx.type == Transaction.typeIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
        if (tx.amount > highestExpense) {
          highestExpense = tx.amount;
        }
      }
    }

    return {
      'totalTransactions': transactions.length,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': totalIncome - totalExpense,
      'avgTransaction': (totalIncome + totalExpense) / transactions.length,
      'highestExpense': highestExpense,
    };
  }

  /// Get spending trend (up or down)
  Future<Map<String, dynamic>> getSpendingTrend() async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final twoMonthsAgo = DateTime(now.year, now.month - 2, 1);

    final transactions = await DatabaseService().getTransactions();

    double currentMonthTotal = 0;
    double previousMonthTotal = 0;
    double twoMonthsAgoTotal = 0;

    for (final tx in transactions) {
      if (tx.type == Transaction.typeExpense) {
        if (tx.date.isAfter(currentMonth)) {
          currentMonthTotal += tx.amount;
        } else if (tx.date.isAfter(previousMonth)) {
          previousMonthTotal += tx.amount;
        } else if (tx.date.isAfter(twoMonthsAgo)) {
          twoMonthsAgoTotal += tx.amount;
        }
      }
    }

    final trendPercentage = previousMonthTotal != 0
        ? ((currentMonthTotal - previousMonthTotal) / previousMonthTotal) * 100
        : 0;

    return {
      'currentMonth': currentMonthTotal,
      'previousMonth': previousMonthTotal,
      'twoMonthsAgo': twoMonthsAgoTotal,
      'trendPercentage': trendPercentage,
      'isIncreasing': trendPercentage > 0,
    };
  }
}
