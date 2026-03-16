import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_upload_provider.dart';
import '../services/calculation_service.dart';

class CalculationScreen extends StatefulWidget {
  const CalculationScreen({super.key});

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  final TextEditingController _inputController = TextEditingController();
  CalculationResult? _result;
  String? _error;

  void _performCalculation() {
    final provider = context.read<DataUploadProvider>();

    if (provider.uploadedData.isEmpty) {
      setState(() {
        _error = 'Please upload data first';
        _result = null;
      });
      return;
    }

    final input = double.tryParse(_inputController.text);
    if (input == null || input <= 0) {
      setState(() {
        _error = 'Please enter a valid number greater than 0';
        _result = null;
      });
      return;
    }

    try {
      final result = CalculationService.calculate(
        userInput: input,
        uploadedData: provider.uploadedData,
      );

      setState(() {
        _result = result;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _result = null;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate'),
      ),
      body: Consumer<DataUploadProvider>(
        builder: (context, provider, _) {
          if (provider.uploadedData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.data_usage_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Data Uploaded',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please upload data in the Data Upload section\nto perform calculations',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Uploaded data summary
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uploaded Data Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Count: ${provider.dataCount}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sum: ${provider.dataSum.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Avg: ${provider.dataAverage.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Values: ${provider.uploadedData.take(3).map((v) => v.toStringAsFixed(1)).join(', ')}${provider.uploadedData.length > 3 ? '...' : ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Input section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter a Number to Calculate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _inputController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter a number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: const Icon(Icons.calculate),
                              errorText: _error,
                            ),
                            onSubmitted: (_) => _performCalculation(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _performCalculation,
                            icon: const Icon(Icons.calculate),
                            label: const Text('Calculate'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Results section
                  if (_result != null)
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calculation Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ResultRow(
                              label: 'Your Input',
                              value: _result!.userInput.toStringAsFixed(2),
                              color: Colors.blue,
                            ),
                            _ResultRow(
                              label: 'Data Sum',
                              value: _result!.sum.toStringAsFixed(2),
                              color: Colors.purple,
                            ),
                            _ResultRow(
                              label: 'Data Average',
                              value: _result!.average.toStringAsFixed(2),
                              color: Colors.orange,
                            ),
                            _ResultRow(
                              label: 'Data Max',
                              value: _result!.max.toStringAsFixed(2),
                              color: Colors.red,
                            ),
                            _ResultRow(
                              label: 'Data Min',
                              value: _result!.min.toStringAsFixed(2),
                              color: Colors.teal,
                            ),
                            const Divider(height: 24),
                            _ResultRow(
                              label: 'Total (Input + Sum)',
                              value: _result!.total.toStringAsFixed(2),
                              color: Colors.green,
                              isHighlight: true,
                            ),
                            _ResultRow(
                              label: 'Your % of Total',
                              value:
                                  '${_result!.userInputPercentage.toStringAsFixed(2)}%',
                              color: Colors.indigo,
                              isHighlight: true,
                            ),
                            _ResultRow(
                              label: 'Difference from Average',
                              value: _result!.difference.toStringAsFixed(2),
                              color: _result!.difference > 0
                                  ? Colors.green
                                  : Colors.red,
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isHighlight;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.color,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isHighlight ? 14 : 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
