import 'package:flutter/material.dart';
import 'dart:ui';

class CalculatorTab extends StatefulWidget {
  const CalculatorTab({Key? key}) : super(key: key);

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  String _display = '0';
  String _operation = '';
  double _firstNumber = 0;
  double _secondNumber = 0;
  bool _waitingForOperand = false;
  String _history = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _clearAll();
      } else if (value == 'CE') {
        _clearEntry();
      } else if (value == '⌫') {
        _backspace();
      } else if (value == '±') {
        _toggleSign();
      } else if (value == '%') {
        _percentage();
      } else if (value == '=') {
        if (_operation.isNotEmpty && !_waitingForOperand) {
          _secondNumber = double.parse(_display);
          _calculate();
        }
      } else if (['+', '-', '×', '÷'].contains(value)) {
        if (_operation.isNotEmpty && !_waitingForOperand) {
          _secondNumber = double.parse(_display);
          _calculate();
        }
        _firstNumber = double.parse(_display);
        _operation = value;
        _waitingForOperand = true;
        _history = '$_firstNumber $value';
      } else if (value == '.') {
        if (_waitingForOperand) {
          _display = '0.';
          _waitingForOperand = false;
        } else if (!_display.contains('.')) {
          _display += '.';
        }
      } else {
        if (_waitingForOperand) {
          _display = value;
          _waitingForOperand = false;
        } else {
          _display = _display == '0' ? value : _display + value;
        }
      }
    });
  }

  void _clearAll() {
    _display = '0';
    _operation = '';
    _firstNumber = 0;
    _secondNumber = 0;
    _waitingForOperand = false;
    _history = '';
  }

  void _clearEntry() {
    _display = '0';
  }

  void _backspace() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
  }

  void _toggleSign() {
    if (_display != '0' && _display != 'Error') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    }
  }

  void _percentage() {
    if (_display != '0' && _display != 'Error') {
      double value = double.parse(_display);
      _display = (value / 100).toString();
    }
  }

  void _calculate() {
    double result = 0;
    switch (_operation) {
      case '+':
        result = _firstNumber + _secondNumber;
        break;
      case '-':
        result = _firstNumber - _secondNumber;
        break;
      case '×':
        result = _firstNumber * _secondNumber;
        break;
      case '÷':
        if (_secondNumber != 0) {
          result = _firstNumber / _secondNumber;
        } else {
          _display = 'Error';
          _operation = '';
          _firstNumber = 0;
          _secondNumber = 0;
          _waitingForOperand = false;
          _history = '';
          return;
        }
        break;
    }

    // Format result to remove unnecessary decimal places
    if (result == result.toInt()) {
      _display = result.toInt().toString();
    } else {
      _display = result.toString();
    }

    _history = '$_firstNumber $_operation $_secondNumber = $_display';
    _operation = '';
    _firstNumber = result;
    _secondNumber = 0;
    _waitingForOperand = false;
  }

  Widget _buildButton(String text,
      {Color? backgroundColor, Color? textColor, double? fontSize}) {
    final isOperator = ['+', '-', '×', '÷', '='].contains(text);
    final isSpecial = ['C', 'CE', '⌫', '±', '%'].contains(text);
    final isNumber = RegExp(r'^[0-9]$').hasMatch(text);

    return Container(
      margin: const EdgeInsets.all(3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: backgroundColor != null
                    ? [backgroundColor, backgroundColor.withOpacity(0.8)]
                    : isOperator
                        ? [
                            const Color(0xFFFF9500),
                            const Color(0xFFFF9500).withOpacity(0.8),
                          ]
                        : isSpecial
                            ? [
                                const Color(0xFFA6A6A6),
                                const Color(0xFFA6A6A6).withOpacity(0.8),
                              ]
                            : isNumber
                                ? [
                                    const Color(0xFF333333),
                                    const Color(0xFF333333).withOpacity(0.8),
                                  ]
                                : [
                                    const Color(0xFF333333),
                                    const Color(0xFF333333).withOpacity(0.8),
                                  ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onButtonPressed(text),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 75,
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor ??
                          (isOperator ? Colors.white : Colors.white),
                      fontSize: fontSize ?? 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                      'Calculator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),

              // History Display
              if (_history.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _history,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),

              // Main Display
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  _display,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _display.length > 8 ? 28 : 42,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),

              // Calculator buttons
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Row 1: C, CE, ⌫, ÷
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildButton('C')),
                            Expanded(child: _buildButton('CE')),
                            Expanded(child: _buildButton('⌫', fontSize: 20)),
                            Expanded(child: _buildButton('÷')),
                          ],
                        ),
                      ),
                      // Row 2: 7, 8, 9, ×
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildButton('7')),
                            Expanded(child: _buildButton('8')),
                            Expanded(child: _buildButton('9')),
                            Expanded(child: _buildButton('×')),
                          ],
                        ),
                      ),
                      // Row 3: 4, 5, 6, -
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildButton('4')),
                            Expanded(child: _buildButton('5')),
                            Expanded(child: _buildButton('6')),
                            Expanded(child: _buildButton('-')),
                          ],
                        ),
                      ),
                      // Row 4: 1, 2, 3, +
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildButton('1')),
                            Expanded(child: _buildButton('2')),
                            Expanded(child: _buildButton('3')),
                            Expanded(child: _buildButton('+')),
                          ],
                        ),
                      ),
                      // Row 5: ±, 0, ., =
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: _buildButton('±')),
                            Expanded(
                              flex: 2,
                              child: _buildButton('0'),
                            ),
                            Expanded(child: _buildButton('.')),
                            Expanded(child: _buildButton('=')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
