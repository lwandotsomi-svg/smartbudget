class CalculationResult {
  final double userInput;
  final List<double> uploadedData;
  final double sum;
  final double average;
  final double max;
  final double min;
  final double total;
  final double userInputPercentage;
  final double difference;

  CalculationResult({
    required this.userInput,
    required this.uploadedData,
    required this.sum,
    required this.average,
    required this.max,
    required this.min,
    required this.total,
    required this.userInputPercentage,
    required this.difference,
  });
}

class CalculationService {
  /// Calculate results based on uploaded data and user input
  static CalculationResult calculate({
    required double userInput,
    required List<double> uploadedData,
  }) {
    if (uploadedData.isEmpty) {
      throw Exception('No uploaded data available for calculation');
    }

    if (userInput <= 0) {
      throw Exception('User input must be greater than 0');
    }

    // Calculate statistics from uploaded data
    final sum = uploadedData.fold<double>(0, (a, b) => a + b);
    final average = sum / uploadedData.length;
    final max = uploadedData.reduce((a, b) => a > b ? a : b);
    final min = uploadedData.reduce((a, b) => a < b ? a : b);
    final total = sum + userInput;

    // Calculate user input as percentage of total
    final userInputPercentage = (userInput / total) * 100;

    // Calculate difference between user input and average
    final difference = userInput - average;

    return CalculationResult(
      userInput: userInput,
      uploadedData: uploadedData,
      sum: sum,
      average: average,
      max: max,
      min: min,
      total: total,
      userInputPercentage: userInputPercentage,
      difference: difference,
    );
  }

  /// Get summary statistics
  static Map<String, double> getSummary(List<double> data) {
    if (data.isEmpty) {
      return {};
    }

    final sum = data.fold<double>(0, (a, b) => a + b);
    final average = sum / data.length;
    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);

    return {
      'sum': sum,
      'average': average,
      'max': max,
      'min': min,
      'count': data.length.toDouble(),
    };
  }

  /// Format number to 2 decimal places
  static String formatNumber(double number) {
    return number.toStringAsFixed(2);
  }
}
