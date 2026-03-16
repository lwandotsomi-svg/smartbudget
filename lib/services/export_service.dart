import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path_util;
import '../models/transaction.dart';
import 'database_service.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();

  factory ExportService() => _instance;

  ExportService._internal();

  /// Export all transactions to CSV file
  Future<File?> exportTransactionsToCSV() async {
    try {
      final transactions = await DatabaseService().getTransactions();

      if (transactions.isEmpty) {
        throw Exception('No transactions to export');
      }

      // Create CSV content
      final StringBuffer csv = StringBuffer();
      csv.writeln(
          'ID,Title,Amount,Date,Category,Type,Notes,IsRecurring,RecurringPattern');

      for (final tx in transactions) {
        csv.writeln(
          '${_escapeCSV(tx.id)},'
          '${_escapeCSV(tx.title)},'
          '${tx.amount},'
          '${tx.date.toIso8601String()},'
          '${_escapeCSV(tx.category)},'
          '${tx.type},'
          '${_escapeCSV(tx.notes ?? "")},'
          '${tx.isRecurring ? 1 : 0},'
          '${tx.recurringPattern ?? ""}',
        );
      }

      return await _saveToFile(
          'transactions_${_getTimestamp()}.csv', csv.toString());
    } catch (e) {
      print('Error exporting transactions: $e');
      return null;
    }
  }

  /// Export all budgets to CSV file
  Future<File?> exportBudgetsToCSV() async {
    try {
      final budgets = await DatabaseService().getBudgets();

      if (budgets.isEmpty) {
        throw Exception('No budgets to export');
      }

      final StringBuffer csv = StringBuffer();
      csv.writeln('ID,Name,Amount,Category');

      for (final budget in budgets) {
        csv.writeln(
          '${_escapeCSV(budget.id)},'
          '${_escapeCSV(budget.name)},'
          '${budget.amount},'
          '${_escapeCSV(budget.category)}',
        );
      }

      return await _saveToFile(
          'budgets_${_getTimestamp()}.csv', csv.toString());
    } catch (e) {
      print('Error exporting budgets: $e');
      return null;
    }
  }

  /// Export transaction summary report
  Future<File?> exportTransactionSummary() async {
    try {
      final transactions = await DatabaseService().getTransactions();

      final StringBuffer report = StringBuffer();
      report.writeln('==== Transaction Summary Report ====');
      report.writeln('Generated: ${DateTime.now()}');
      report.writeln('');

      // Calculate totals
      double totalIncome = 0;
      double totalExpense = 0;
      final Map<String, double> categoryTotals = {};

      for (final tx in transactions) {
        if (tx.type == Transaction.typeIncome) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }

        categoryTotals[tx.category] =
            (categoryTotals[tx.category] ?? 0) + tx.amount;
      }

      report.writeln('Total Income: ${totalIncome.toStringAsFixed(2)}');
      report.writeln('Total Expense: ${totalExpense.toStringAsFixed(2)}');
      report.writeln('Net: ${(totalIncome - totalExpense).toStringAsFixed(2)}');
      report.writeln('');

      report.writeln('--- By Category ---');
      categoryTotals.forEach((category, amount) {
        report.writeln('$category: ${amount.toStringAsFixed(2)}');
      });

      report.writeln('');
      report.writeln('Total Transactions: ${transactions.length}');

      return await _saveToFile(
          'summary_${_getTimestamp()}.txt', report.toString());
    } catch (e) {
      print('Error generating summary: $e');
      return null;
    }
  }

  /// Export complete database backup to JSON
  Future<File?> exportCompleteBackup() async {
    try {
      final db = DatabaseService();
      final transactions = await db.getTransactions();
      final budgets = await db.getBudgets();
      final categories = await db.getCategories();

      final Map<String, dynamic> backup = {
        'backup_date': DateTime.now().toIso8601String(),
        'version': 1,
        'transactions': transactions.map((t) => t.toMap()).toList(),
        'budgets': budgets.map((b) => b.toMap()).toList(),
        'categories': categories.map((c) => c.toMap()).toList(),
      };

      // Convert to JSON-like format
      final jsonContent = _mapToJsonString(backup);
      return await _saveToFile('backup_${_getTimestamp()}.json', jsonContent);
    } catch (e) {
      print('Error creating backup: $e');
      return null;
    }
  }

  /// Helper to escape CSV values
  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Helper to get timestamp string
  String _getTimestamp() {
    return DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
  }

  /// Helper to save file to documents directory
  Future<File> _saveToFile(String filename, String content) async {
    final directory = Directory('/storage/emulated/0/Documents/SmartBudget');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File(path_util.join(directory.path, filename));
    await file.writeAsString(content);
    return file;
  }

  /// Convert map to JSON-like string
  String _mapToJsonString(Map<String, dynamic> map, {int indent = 0}) {
    final StringBuffer buffer = StringBuffer();
    final String indentStr = '  ' * indent;
    final String nextIndentStr = '  ' * (indent + 1);

    buffer.write('{\n');

    final entries = map.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('$nextIndentStr"${entry.key}": ');

      if (entry.value is Map) {
        buffer.write(_mapToJsonString(entry.value, indent: indent + 1));
      } else if (entry.value is List) {
        buffer.write(_listToJsonString(entry.value, indent: indent + 1));
      } else if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else {
        buffer.write(entry.value);
      }

      if (i < entries.length - 1) {
        buffer.write(',');
      }
      buffer.write('\n');
    }

    buffer.write('$indentStr}');
    return buffer.toString();
  }

  /// Convert list to JSON-like string
  String _listToJsonString(List list, {int indent = 0}) {
    final StringBuffer buffer = StringBuffer();
    final String nextIndentStr = '  ' * (indent + 1);
    final String indentStr = '  ' * indent;

    buffer.write('[\n');

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      buffer.write(nextIndentStr);

      if (item is Map) {
        final mapItem = item as Map<String, dynamic>;
        buffer.write(_mapToJsonString(mapItem, indent: indent + 1));
      } else if (item is List) {
        buffer.write(_listToJsonString(item, indent: indent + 1));
      } else if (item is String) {
        buffer.write('"$item"');
      } else {
        buffer.write(item);
      }

      if (i < list.length - 1) {
        buffer.write(',');
      }
      buffer.write('\n');
    }

    buffer.write('$indentStr]');
    return buffer.toString();
  }
}
