class CarFeeCalculator {
  // Exchange rates (from CSV analysis)
  static const Map<String, double> exchangeRates = {
    'SAR': 3.76, // 1 USD = 3.76 SAR
    'AED': 3.71, // 1 USD = 3.71 AED
    'KWD': 0.31, // 1 USD = 0.31 KWD
    'BHD': 0.38, // 1 USD = 0.38 BHD
    'OMR': 0.39, // 1 USD = 0.39 OMR
    'QAR': 3.70, // 1 USD = 3.70 QAR
  };

  // Customs rates for different countries
  static const Map<String, double> customsRates = {
    'KSA': 0.20, // 20%
    'KSA_COMPANY': 0.05, // 5%
    'UAE': 0.10, // 10%
    'KUWAIT': 0.05, // 5%
    'BAHRAIN': 0.15, // 15%
    'OMAN': 0.10, // 10%
    'QATAR': 0.05, // 5%
  };

  // Calculation modes
  static const List<String> calculationModes = [
    'CALCULATION KSA',
    'CALCULATION KSA WITH 5% SAUDI FEES FOR COMPANY',
    'CALCULATION UAE',
    'CALCULATION KUWAIT',
    'CALCULATION BAHRAIN',
    'CALCULATION OMAN',
    'CALCULATION QATAR',
    'CALCULATION USA → KSA',
    'CALCULATION USA → UAE',
    'CALCULATION SHIPPING INSURANCE KSA',
    'CALCULATION SHIPPING INSURANCE UAE',
    'CALCULATION SHIPPING INSURANCE KWD',
    'CALCULATION SHIPPING INSURANCE BHD',
    'CALCULATION SHIPPING INSURANCE OMR',
    'CALCULATION SHIPPING INSURANCE QAR',
  ];

  // Input parameters
  static const Map<String, String> inputLabels = {
    'deposit': 'العربون (Deposit)',
    'carValue': 'قيمة شراء السيارة (Car Purchase Value)',
    'auctionFees': 'رسوم المزاد (Auction Fees)',
    'clearanceFees': 'رسوم تخليص السيارة من امريكا (Clearance Fees)',
    'titleFees':
        'رسوم التايتل ورسوم اللوحة المؤقته (Title & Temporary Plate Fees)',
    'domesticShipping': 'رسوم الشحن الداخلي (Domestic Shipping)',
    'specialClearance':
        'رسوم خاصة بتخليص السيارة من امريكا (Special Clearance)',
    'insuranceRequired': 'قيمة التأمين المطلوبة من العميل (Insurance Required)',
    'gblInsurance': 'قيمة التأمين ل GBL (GBL Insurance)',
  };

  static String getCurrencyCode(String mode) {
    if (mode.contains('KSA')) return 'SAR';
    if (mode.contains('UAE')) return 'AED';
    if (mode.contains('KUWAIT')) return 'KWD';
    if (mode.contains('BAHRAIN')) return 'BHD';
    if (mode.contains('OMAN')) return 'OMR';
    if (mode.contains('QATAR')) return 'QAR';
    return 'USD';
  }

  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'SAR':
        return 'ريال';
      case 'AED':
        return 'د.إ.';
      case 'KWD':
        return 'د.ك.';
      case 'BHD':
        return 'د.ب.';
      case 'OMR':
        return 'ر.ع.';
      case 'QAR':
        return 'ر.ق.';
      default:
        return 'دولار';
    }
  }

  static double convertToLocalCurrency(double usdAmount, String currencyCode) {
    return usdAmount * (exchangeRates[currencyCode] ?? 1.0);
  }

  static double convertToUSD(double localAmount, String currencyCode) {
    return localAmount / (exchangeRates[currencyCode] ?? 1.0);
  }

  static Map<String, dynamic> calculateStandardMode({
    required String mode,
    required double deposit,
    required double carValue,
    required double auctionFees,
    required double clearanceFees,
  }) {
    final currencyCode = getCurrencyCode(mode);
    final currencySymbol = getCurrencySymbol(currencyCode);

    // Determine customs rate
    double customsRate = 0.0;
    if (mode.contains('KSA WITH 5%')) {
      customsRate = customsRates['KSA_COMPANY']!;
    } else if (mode.contains('KSA')) {
      customsRate = customsRates['KSA']!;
    } else if (mode.contains('UAE')) {
      customsRate = customsRates['UAE']!;
    } else if (mode.contains('KUWAIT')) {
      customsRate = customsRates['KUWAIT']!;
    } else if (mode.contains('BAHRAIN')) {
      customsRate = customsRates['BAHRAIN']!;
    } else if (mode.contains('OMAN')) {
      customsRate = customsRates['OMAN']!;
    } else if (mode.contains('QATAR')) {
      customsRate = customsRates['QATAR']!;
    }

    // Calculations
    final carBeforeDeposit = deposit + carValue + auctionFees + clearanceFees;
    final carAfterDeposit = carBeforeDeposit - deposit;
    final customsAmount = carAfterDeposit * customsRate;
    final finalPrice = carAfterDeposit + customsAmount;

    return {
      'deposit': {
        'usd': deposit,
        'local': convertToLocalCurrency(deposit, currencyCode),
        'currency': currencySymbol,
      },
      'carValue': {
        'usd': carValue,
        'local': convertToLocalCurrency(carValue, currencyCode),
        'currency': currencySymbol,
      },
      'auctionFees': {
        'usd': auctionFees,
        'local': convertToLocalCurrency(auctionFees, currencyCode),
        'currency': currencySymbol,
      },
      'clearanceFees': {
        'usd': clearanceFees,
        'local': convertToLocalCurrency(clearanceFees, currencyCode),
        'currency': currencySymbol,
      },
      'carBeforeDeposit': {
        'usd': carBeforeDeposit,
        'local': convertToLocalCurrency(carBeforeDeposit, currencyCode),
        'currency': currencySymbol,
      },
      'carAfterDeposit': {
        'usd': carAfterDeposit,
        'local': convertToLocalCurrency(carAfterDeposit, currencyCode),
        'currency': currencySymbol,
      },
      'customs': {
        'usd': customsAmount,
        'local': convertToLocalCurrency(customsAmount, currencyCode),
        'currency': currencySymbol,
        'rate': customsRate,
      },
      'finalPrice': {
        'usd': finalPrice,
        'local': convertToLocalCurrency(finalPrice, currencyCode),
        'currency': currencySymbol,
      },
      'currencyCode': currencyCode,
    };
  }

  static Map<String, dynamic> calculateUSAMode({
    required String mode,
    required double deposit,
    required double carValue,
    required double auctionFees,
    required double titleFees,
    required double domesticShipping,
    required double specialClearance,
  }) {
    final currencyCode = getCurrencyCode(mode);
    final currencySymbol = getCurrencySymbol(currencyCode);

    // Determine customs rate
    double customsRate = 0.0;
    if (mode.contains('KSA')) {
      customsRate = customsRates['KSA']!;
    } else if (mode.contains('UAE')) {
      customsRate = customsRates['UAE']!;
    }

    // Calculations for USA mode
    final carBeforeDeposit = deposit +
        carValue +
        auctionFees +
        titleFees +
        domesticShipping +
        specialClearance;
    final carAfterDeposit = carBeforeDeposit - deposit;
    final customsAmount = carAfterDeposit * customsRate;
    final finalPrice = carAfterDeposit + customsAmount;

    return {
      'deposit': {
        'usd': deposit,
        'local': convertToLocalCurrency(deposit, currencyCode),
        'currency': currencySymbol,
      },
      'carValue': {
        'usd': carValue,
        'local': convertToLocalCurrency(carValue, currencyCode),
        'currency': currencySymbol,
      },
      'auctionFees': {
        'usd': auctionFees,
        'local': convertToLocalCurrency(auctionFees, currencyCode),
        'currency': currencySymbol,
      },
      'titleFees': {
        'usd': titleFees,
        'local': convertToLocalCurrency(titleFees, currencyCode),
        'currency': currencySymbol,
      },
      'domesticShipping': {
        'usd': domesticShipping,
        'local': convertToLocalCurrency(domesticShipping, currencyCode),
        'currency': currencySymbol,
      },
      'specialClearance': {
        'usd': specialClearance,
        'local': convertToLocalCurrency(specialClearance, currencyCode),
        'currency': currencySymbol,
      },
      'carBeforeDeposit': {
        'usd': carBeforeDeposit,
        'local': convertToLocalCurrency(carBeforeDeposit, currencyCode),
        'currency': currencySymbol,
      },
      'carAfterDeposit': {
        'usd': carAfterDeposit,
        'local': convertToLocalCurrency(carAfterDeposit, currencyCode),
        'currency': currencySymbol,
      },
      'customs': {
        'usd': customsAmount,
        'local': convertToLocalCurrency(customsAmount, currencyCode),
        'currency': currencySymbol,
        'rate': customsRate,
      },
      'finalPrice': {
        'usd': finalPrice,
        'local': convertToLocalCurrency(finalPrice, currencyCode),
        'currency': currencySymbol,
      },
      'currencyCode': currencyCode,
    };
  }

  static Map<String, dynamic> calculateShippingInsuranceMode({
    required String mode,
    required double carValue,
    required double insuranceRequired,
    required double gblInsurance,
    required double clearanceFees,
  }) {
    final currencyCode = getCurrencyCode(mode);
    final currencySymbol = getCurrencySymbol(currencyCode);

    // For shipping insurance, the final amount is just the sum of all components
    final finalAmount =
        carValue + insuranceRequired + gblInsurance + clearanceFees;

    return {
      'carValue': {
        'usd': carValue,
        'local': convertToLocalCurrency(carValue, currencyCode),
        'currency': currencySymbol,
      },
      'insuranceRequired': {
        'usd': insuranceRequired,
        'local': convertToLocalCurrency(insuranceRequired, currencyCode),
        'currency': currencySymbol,
      },
      'gblInsurance': {
        'usd': gblInsurance,
        'local': convertToLocalCurrency(gblInsurance, currencyCode),
        'currency': currencySymbol,
      },
      'clearanceFees': {
        'usd': clearanceFees,
        'local': convertToLocalCurrency(clearanceFees, currencyCode),
        'currency': currencySymbol,
      },
      'finalAmount': {
        'usd': finalAmount,
        'local': convertToLocalCurrency(finalAmount, currencyCode),
        'currency': currencySymbol,
      },
      'currencyCode': currencyCode,
    };
  }

  static Map<String, dynamic> calculate({
    required String mode,
    required Map<String, double> inputs,
  }) {
    if (mode.contains('SHIPPING INSURANCE')) {
      return calculateShippingInsuranceMode(
        mode: mode,
        carValue: inputs['carValue'] ?? 0,
        insuranceRequired: inputs['insuranceRequired'] ?? 0,
        gblInsurance: inputs['gblInsurance'] ?? 0,
        clearanceFees: inputs['clearanceFees'] ?? 0,
      );
    } else if (mode.contains('USA')) {
      return calculateUSAMode(
        mode: mode,
        deposit: inputs['deposit'] ?? 0,
        carValue: inputs['carValue'] ?? 0,
        auctionFees: inputs['auctionFees'] ?? 0,
        titleFees: inputs['titleFees'] ?? 0,
        domesticShipping: inputs['domesticShipping'] ?? 0,
        specialClearance: inputs['specialClearance'] ?? 0,
      );
    } else {
      return calculateStandardMode(
        mode: mode,
        deposit: inputs['deposit'] ?? 0,
        carValue: inputs['carValue'] ?? 0,
        auctionFees: inputs['auctionFees'] ?? 0,
        clearanceFees: inputs['clearanceFees'] ?? 0,
      );
    }
  }

  static List<String> getRequiredInputs(String mode) {
    if (mode.contains('SHIPPING INSURANCE')) {
      return ['carValue', 'insuranceRequired', 'gblInsurance', 'clearanceFees'];
    } else if (mode.contains('USA')) {
      return [
        'deposit',
        'carValue',
        'auctionFees',
        'titleFees',
        'domesticShipping',
        'specialClearance'
      ];
    } else {
      return ['deposit', 'carValue', 'auctionFees', 'clearanceFees'];
    }
  }
}
