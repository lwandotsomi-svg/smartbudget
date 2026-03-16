import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/reports_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late ReportsService _reportsService;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _reportsService = ReportsService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: _TabButton(
                      label: ['Summary', 'Expenses', 'Income', 'Trends'][index],
                      isSelected: _selectedTab == index,
                      onTap: () => setState(() => _selectedTab = index),
                    ),
                  ),
                ),
              ),
            ),
            if (_selectedTab == 0) _SummaryTab(service: _reportsService),
            if (_selectedTab == 1) _ExpensesTab(service: _reportsService),
            if (_selectedTab == 2) _IncomeTab(service: _reportsService),
            if (_selectedTab == 3) _TrendsTab(service: _reportsService),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final ReportsService service;

  const _SummaryTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: service.getSummaryStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatCard(
                title: 'Total Transactions',
                value: '${stats['totalTransactions']}',
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Total Income',
                value:
                    '\$${(stats['totalIncome'] as double).toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Total Expense',
                value:
                    '\$${(stats['totalExpense'] as double).toStringAsFixed(2)}',
                icon: Icons.trending_down,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Net Balance',
                value: '\$${(stats['balance'] as double).toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: (stats['balance'] as double) >= 0
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Average Transaction',
                value:
                    '\$${(stats['avgTransaction'] as double).toStringAsFixed(2)}',
                icon: Icons.calculate,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Highest Expense',
                value:
                    '\$${(stats['highestExpense'] as double).toStringAsFixed(2)}',
                icon: Icons.arrow_upward,
                color: Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final ReportsService service;

  const _ExpensesTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: service.getExpenseByCategoryChart(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No expense data available'),
            ),
          );
        }

        final data = snapshot.data!;
        final total = data.values.fold<double>(0, (a, b) => a + b);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: List.generate(
                          data.length,
                          (index) {
                            final entry = data.entries.elementAt(index);
                            final percentage = (entry.value / total) * 100;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${percentage.toStringAsFixed(1)}%',
                              color: _getColor(index),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Breakdown by Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...data.entries.map((entry) {
                final percentage = (entry.value / total) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color:
                              _getColor(data.keys.toList().indexOf(entry.key)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(entry.key),
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _IncomeTab extends StatelessWidget {
  final ReportsService service;

  const _IncomeTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: service.getIncomeByCategoryChart(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No income data available'),
            ),
          );
        }

        final data = snapshot.data!;
        final total = data.values.fold<double>(0, (a, b) => a + b);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: List.generate(
                          data.length,
                          (index) {
                            final entry = data.entries.elementAt(index);
                            final percentage = (entry.value / total) * 100;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${percentage.toStringAsFixed(1)}%',
                              color: _getIncomeColor(index),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Breakdown by Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...data.entries.map((entry) {
                final percentage = (entry.value / total) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getIncomeColor(
                              data.keys.toList().indexOf(entry.key)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(entry.key),
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _TrendsTab extends StatelessWidget {
  final ReportsService service;

  const _TrendsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: service.getSpendingTrend(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final trend = snapshot.data!;
        final isIncreasing = trend['isIncreasing'] as bool;
        final percentage =
            (trend['trendPercentage'] as double).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: isIncreasing ? Colors.red.shade50 : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Spending Trend',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isIncreasing ? 'Increased' : 'Decreased',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isIncreasing ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isIncreasing ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isIncreasing
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Monthly Comparison',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _TrendComparisonCard(
                label: 'Two Months Ago',
                amount: trend['twoMonthsAgo'] as double,
              ),
              const SizedBox(height: 8),
              _TrendComparisonCard(
                label: 'Last Month',
                amount: trend['previousMonth'] as double,
              ),
              const SizedBox(height: 8),
              _TrendComparisonCard(
                label: 'This Month (Current)',
                amount: trend['currentMonth'] as double,
                isHighlight: true,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isIncreasing
                            ? 'Your spending has increased by $percentage% compared to last month.'
                            : 'Your spending has decreased by $percentage% compared to last month.',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrendComparisonCard extends StatelessWidget {
  final String label;
  final double amount;
  final bool isHighlight;

  const _TrendComparisonCard({
    required this.label,
    required this.amount,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isHighlight ? Colors.blue.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                fontSize: isHighlight ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getColor(int index) {
  final colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];
  return colors[index % colors.length];
}

Color _getIncomeColor(int index) {
  final colors = [
    Colors.green.shade700,
    Colors.green.shade600,
    Colors.green.shade500,
    Colors.green.shade400,
    Colors.teal.shade600,
    Colors.cyan.shade600,
    Colors.lightGreen.shade600,
  ];
  return colors[index % colors.length];
}
