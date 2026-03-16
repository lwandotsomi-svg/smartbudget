import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../services/export_service.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'light';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            _SettingSection(
              title: 'Appearance',
              children: [
                _SettingTile(
                  title: 'Theme',
                  subtitle: 'Light / Dark',
                  trailing: DropdownButton<String>(
                    value: _selectedTheme,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedTheme = value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'light',
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: 'dark',
                        child: Text('Dark'),
                      ),
                      DropdownMenuItem(
                        value: 'system',
                        child: Text('System'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Notifications Section
            _SettingSection(
              title: 'Notifications',
              children: [
                _SettingTile(
                  title: 'Goal Reminders',
                  subtitle: 'Daily notifications for your goals',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
              ],
            ),
            // Data & Privacy Section
            _SettingSection(
              title: 'Data & Privacy',
              children: [
                _SettingTile(
                  title: 'Export Transactions',
                  subtitle: 'Export all transactions to CSV',
                  onTap: () => _exportTransactions(context),
                ),
                _SettingTile(
                  title: 'Export Budgets',
                  subtitle: 'Export all budgets to CSV',
                  onTap: () => _exportBudgets(context),
                ),
                _SettingTile(
                  title: 'Export Summary Report',
                  subtitle: 'Export spending summary',
                  onTap: () => _exportSummary(context),
                ),
                _SettingTile(
                  title: 'Create Backup',
                  subtitle: 'Backup all data to JSON',
                  onTap: () => _createBackup(context),
                ),
              ],
            ),
            // Categories Section
            _SettingSection(
              title: 'Categories',
              children: [
                _SettingTile(
                  title: 'Manage Categories',
                  subtitle: 'Add, edit, or delete categories',
                  onTap: () => _showCategoriesDialog(context),
                ),
              ],
            ),
            // Danger Zone
            _SettingSection(
              title: 'Danger Zone',
              children: [
                _SettingTile(
                  title: 'Reset All Data',
                  subtitle: 'Permanently delete all data',
                  textColor: Colors.red,
                  onTap: () => _showResetConfirmation(context),
                ),
              ],
            ),
            // About Section
            _SettingSection(
              title: 'About',
              children: [
                const _SettingTile(
                  title: 'SmartBudget',
                  subtitle: 'Version 1.0.0',
                ),
                const _SettingTile(
                  title: 'Created by',
                  subtitle: 'Administrator',
                ),
                const _SettingTile(
                  title: 'Privacy',
                  subtitle: '100% offline • No data collection',
                ),
                _SettingTile(
                  title: 'Source Code',
                  subtitle: 'View on GitHub',
                  onTap: () => _showSourceCodeInfo(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransactions(BuildContext context) async {
    final file = await ExportService().exportTransactionsToCSV();
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to ${file.path}'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  Future<void> _exportBudgets(BuildContext context) async {
    final file = await ExportService().exportBudgetsToCSV();
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to ${file.path}'),
        ),
      );
    }
  }

  Future<void> _exportSummary(BuildContext context) async {
    final file = await ExportService().exportTransactionSummary();
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved to ${file.path}'),
        ),
      );
    }
  }

  Future<void> _createBackup(BuildContext context) async {
    final file = await ExportService().exportCompleteBackup();
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup created at ${file.path}'),
        ),
      );
    }
  }

  void _showCategoriesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const CategoryManagementDialog(),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your data including transactions, budgets, and goals. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService().clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been reset'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSourceCodeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('SmartBudget'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Finance Management',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Version: 1.0.0'),
              SizedBox(height: 8),
              Text('Created by: Administrator'),
              SizedBox(height: 8),
              Text('License: MIT'),
              SizedBox(height: 12),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Track income and expenses'),
              Text('• Manage budgets by category'),
              Text('• Set and monitor financial goals'),
              Text('• Detailed financial analytics'),
              Text('• 100% offline • No data collection'),
              SizedBox(height: 12),
              Text(
                'Repository: github.com/lwandotsomi-svg/smartbudget',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        ...children,
        const Divider(height: 0),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  const _SettingTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: textColor?.withOpacity(0.7)),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class CategoryManagementDialog extends StatefulWidget {
  const CategoryManagementDialog({super.key});

  @override
  State<CategoryManagementDialog> createState() =>
      _CategoryManagementDialogState();
}

class _CategoryManagementDialogState extends State<CategoryManagementDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.categories.isEmpty) {
                  return const Text('No categories');
                }

                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      return ListTile(
                        leading: Text(category.icon ?? '📌'),
                        title: Text(category.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            provider.deleteCategory(category.id);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
