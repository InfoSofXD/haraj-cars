import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../tools/calculator_viewmodel.dart';
import '../../../services/car_fee_calculator.dart';
import '../../../tools/Palette/theme.dart';
import '../../../tools/Palette/gradients.dart';

class CalculatorTab extends StatefulWidget {
  const CalculatorTab({Key? key}) : super(key: key);

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  final List<TextEditingController> _controllers = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalculatorViewModel>().reset();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers(CalculatorViewModel viewModel) {
    // Dispose existing controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();

    // Create new controllers for current mode inputs
    final requiredInputs =
        CarFeeCalculator.getRequiredInputs(viewModel.selectedMode);
    for (String input in requiredInputs) {
      final controller = TextEditingController();
      controller.text = viewModel.inputs[input]?.toString() ?? '0';
      controller.addListener(() {
        final value = double.tryParse(controller.text) ?? 0.0;
        viewModel.updateInput(input, value);
      });
      _controllers.add(controller);
    }
  }

  Widget _buildInputField(
      String key, String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Tajawal',
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontFamily: 'Tajawal',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixText: 'USD',
                suffixStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationResult(
      Map<String, dynamic> result, String currencyCode, String currencySymbol) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نتائج الحساب',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 16),
          ...result.entries.map((entry) {
            if (entry.key == 'currencyCode') return const SizedBox.shrink();

            final data = entry.value as Map<String, dynamic>;
            final usdAmount = data['usd'] as double;
            final localAmount = data['local'] as double;
            final currency = data['currency'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getArabicLabel(entry.key),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${usdAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      Text(
                        '${localAmount.toStringAsFixed(2)} $currency',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getArabicLabel(String key) {
    const labels = {
      'deposit': 'العربون',
      'carValue': 'قيمة شراء السيارة',
      'auctionFees': 'رسوم المزاد',
      'clearanceFees': 'رسوم تخليص السيارة من امريكا',
      'titleFees': 'رسوم التايتل ورسوم اللوحة المؤقته',
      'domesticShipping': 'رسوم الشحن الداخلي',
      'specialClearance': 'رسوم خاصة بتخليص السيارة من امريكا',
      'insuranceRequired': 'قيمة التأمين المطلوبة من العميل',
      'gblInsurance': 'قيمة التأمين ل GBL',
      'discountPercentage': 'نسبة الخصم',
      'fileNumber': 'رقم الملف',
      'fullAmountBDAS': 'المبلغ الكامل للفاتورة BDAS',
      'fullAmountOH': 'المبلغ الكامل للفاتورة OH',
      'discountAmount': 'مبلغ الخصم',
      'carBeforeDeposit': 'قيمة السيارة حتى وصولها الى الميناء قبل خصم العربون',
      'carAfterDeposit': 'قيمة السيارة حتى وصولها الى الميناء بعد خصم العربون',
      'carAfterDiscount': 'قيمة السيارة بعد الخصم',
      'customs': 'رسوم الجمارك والضريبة',
      'finalPrice': 'السعر شامل',
      'finalAmount': 'المبلغ النهائي',
      'transferAmount': 'المبلغ المطلوب تحويلة الى المعرض',
      'finalAmountKSA': 'المبلغ النهائي للسعودية',
    };
    return labels[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorViewModel>(
      builder: (context, viewModel, child) {
        // Initialize controllers when mode changes
        if (_controllers.length !=
            CarFeeCalculator.getRequiredInputs(viewModel.selectedMode).length) {
          _initializeControllers(viewModel);
        }

        return Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? DarkGradient.main
                : LightGradient.main,
          ),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calculate,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'حاسبة رسوم استيراد السيارات',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mode Selection
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'نوع الحساب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: viewModel.selectedMode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            dropdownColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? dark[800]
                                    : light[800],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                            items: CarFeeCalculator.calculationModes
                                .map((String mode) {
                              return DropdownMenuItem<String>(
                                value: mode,
                                child: Text(
                                  mode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                viewModel.setCalculationMode(newValue);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Input Fields
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'بيانات الحساب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...CarFeeCalculator.getRequiredInputs(
                                  viewModel.selectedMode)
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final inputKey = entry.value;
                            final controller = _controllers.length > index
                                ? _controllers[index]
                                : TextEditingController();
                            return _buildInputField(
                              inputKey,
                              viewModel.getInputLabel(inputKey),
                              controller,
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    // Calculate Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        onPressed:
                            viewModel.canCalculate && !viewModel.isCalculating
                                ? () => viewModel.calculate()
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: viewModel.canCalculate
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? dark[600]
                                  : light[600])
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: viewModel.isCalculating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'حساب الرسوم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                      ),
                    ),

                    // Clear Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: OutlinedButton(
                        onPressed: () => viewModel.clearInputs(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'مسح البيانات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),

                    // Results
                    if (viewModel.calculationResult != null)
                      _buildCalculationResult(
                        viewModel.calculationResult!,
                        viewModel.currencyCode,
                        viewModel.currencySymbol,
                      ),

                    const SizedBox(height: 75),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
