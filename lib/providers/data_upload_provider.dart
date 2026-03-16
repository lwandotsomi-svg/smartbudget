import 'package:flutter/material.dart';

class DataUploadProvider with ChangeNotifier {
  List<double> _uploadedData = [];
  bool _isLoading = false;
  String? _error;

  List<double> get uploadedData => _uploadedData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get dataCount => _uploadedData.length;
  double get dataSum =>
      _uploadedData.fold<double>(0, (sum, value) => sum + value);
  double get dataAverage =>
      _uploadedData.isEmpty ? 0 : dataSum / _uploadedData.length;

  /// Add a single value to uploaded data
  void addValue(double value) {
    try {
      if (value <= 0) {
        _error = 'Value must be greater than 0';
        notifyListeners();
        return;
      }
      _uploadedData.add(value);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add value: $e';
      notifyListeners();
    }
  }

  /// Add multiple values at once
  void addValues(List<double> values) {
    try {
      for (final value in values) {
        if (value <= 0) {
          _error = 'All values must be greater than 0';
          notifyListeners();
          return;
        }
      }
      _uploadedData.addAll(values);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add values: $e';
      notifyListeners();
    }
  }

  /// Remove a value at specific index
  void removeValue(int index) {
    try {
      if (index >= 0 && index < _uploadedData.length) {
        _uploadedData.removeAt(index);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to remove value: $e';
      notifyListeners();
    }
  }

  /// Clear all uploaded data
  void clearData() {
    _uploadedData.clear();
    _error = null;
    notifyListeners();
  }

  /// Replace value at index
  void updateValue(int index, double value) {
    try {
      if (value <= 0) {
        _error = 'Value must be greater than 0';
        notifyListeners();
        return;
      }
      if (index >= 0 && index < _uploadedData.length) {
        _uploadedData[index] = value;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update value: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
