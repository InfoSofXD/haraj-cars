import 'package:flutter/foundation.dart';
import '../services/car_fee_calculator.dart';

class CalculatorViewModel extends ChangeNotifier {
  String _selectedMode = CarFeeCalculator.calculationModes.first;
  Map<String, double> _inputs = {};
  Map<String, dynamic>? _calculationResult;
  bool _isCalculating = false;

  // Getters
  String get selectedMode => _selectedMode;
  Map<String, double> get inputs => _inputs;
  Map<String, dynamic>? get calculationResult => _calculationResult;
  bool get isCalculating => _isCalculating;

  // Initialize inputs for the selected mode
  void _initializeInputs() {
    final requiredInputs = CarFeeCalculator.getRequiredInputs(_selectedMode);
    _inputs = {};
    for (String input in requiredInputs) {
      _inputs[input] = 0.0;
    }
  }

  // Set calculation mode
  void setCalculationMode(String mode) {
    if (_selectedMode != mode) {
      _selectedMode = mode;
      _initializeInputs();
      _calculationResult = null;
      notifyListeners();
    }
  }

  // Update input value
  void updateInput(String key, double value) {
    _inputs[key] = value;
    notifyListeners();
  }

  // Calculate fees
  Future<void> calculate() async {
    if (_isCalculating) return;

    _isCalculating = true;
    notifyListeners();

    try {
      // Simulate async calculation (in case we need to add API calls later)
      await Future.delayed(const Duration(milliseconds: 100));

      _calculationResult = CarFeeCalculator.calculate(
        mode: _selectedMode,
        inputs: _inputs,
      );
    } catch (e) {
      debugPrint('Calculation error: $e');
      _calculationResult = null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  // Clear all inputs
  void clearInputs() {
    _initializeInputs();
    _calculationResult = null;
    notifyListeners();
  }

  // Reset to default state
  void reset() {
    _selectedMode = CarFeeCalculator.calculationModes.first;
    _initializeInputs();
    _calculationResult = null;
    _isCalculating = false;
    notifyListeners();
  }

  // Get input label
  String getInputLabel(String key) {
    return CarFeeCalculator.inputLabels[key] ?? key;
  }

  // Check if all required inputs are filled
  bool get canCalculate {
    final requiredInputs = CarFeeCalculator.getRequiredInputs(_selectedMode);
    return requiredInputs
        .every((input) => _inputs.containsKey(input) && _inputs[input]! > 0);
  }

  // Get currency info for current mode
  String get currencyCode => CarFeeCalculator.getCurrencyCode(_selectedMode);
  String get currencySymbol => CarFeeCalculator.getCurrencySymbol(currencyCode);
}
