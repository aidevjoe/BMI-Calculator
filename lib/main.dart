import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BMICalculatorPage(),
    );
  }
}

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage>
    with SingleTickerProviderStateMixin {
  double _height = 175;
  double _weight = 70;
  double _bmi = 0;
  String _bmiStatus = '';
  Color _statusColor = Colors.black;
  String _healthAdvice = '';
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool _isAsian;

  final Map<String, Map<String, List<double>>> _bmiCategories = {
    'non_asian': {
      'Underweight': [0, 18.5],
      'Normal Weight': [18.5, 25],
      'Overweight': [25, 30],
      'Obese': [30, double.infinity],
    },
    'asian': {
      'Underweight': [0, 18.5],
      'Normal Weight': [18.5, 23],
      'Overweight': [23, 27.5],
      'Obese': [27.5, double.infinity],
    },
  };

  Map<String, List<double>> get categories {
    return _bmiCategories[_isAsian ? 'asian' : 'non_asian']!;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _isAsian = _checkIfAsian();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _checkIfAsian() {
    // 这里可以根据需要添加更多的亚洲国家/地区代码
    final locale = PlatformDispatcher.instance.locale.languageCode;
    List<String> asianLocales = ['zh', 'ja', 'ko', 'vi', 'th', 'ms', 'id'];
    return asianLocales.any((l) => locale.startsWith(l));
  }

  void _calculateBMI() {
    setState(() {
      _bmi = _weight / pow(_height / 100, 2);

      if (_bmi < categories['Normal Weight']![0]) {
        _bmiStatus = 'Underweight';
        _statusColor = Colors.blue;
        _healthAdvice =
            'You may need to gain some weight. Consider consulting a nutritionist for a balanced diet plan.';
      } else if (_bmi < categories['Overweight']![0]) {
        _bmiStatus = 'Normal Weight';
        _statusColor = Colors.green;
        _healthAdvice =
            'You have a healthy weight. Maintain a balanced diet and regular exercise to stay healthy.';
      } else if (_bmi < categories['Obese']![0]) {
        _bmiStatus = 'Overweight';
        _statusColor = Colors.orange;
        _healthAdvice =
            'You may benefit from losing some weight. Focus on a balanced diet and increased physical activity.';
      } else {
        _bmiStatus = 'Obese';
        _statusColor = Colors.red;
        _healthAdvice =
            'Your health may be at risk. Consider consulting a healthcare professional for a personalized weight loss plan.';
      }
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomRuler(
                      label: 'Height',
                      value: _height,
                      minValue: 100,
                      maxValue: 220,
                      unit: 'cm',
                      onChanged: (value) => setState(() => _height = value),
                    ),
                    const SizedBox(height: 12),
                    CustomRuler(
                      label: 'Weight',
                      value: _weight,
                      minValue: 30,
                      maxValue: 150,
                      unit: 'kg',
                      onChanged: (value) => setState(() => _weight = value),
                    ),
                    if (_bmi != 0) _buildBMIResult(),
                    const SizedBox(height: 12),
                    _buildBMICategories(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Calculate", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIResult() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 12),
        child: Column(
          children: [
            ScaleTransition(
              scale: _animation,
              child: Text(
                _bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: _statusColor,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation,
              child: Text(
                _bmiStatus,
                style: TextStyle(
                  fontSize: 24,
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: Text(
                _healthAdvice,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICategories() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text(
              'BMI Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBMICategory('Underweight',
                '< ${categories['Normal Weight']![0]}', Colors.blue),
            _buildBMICategory(
                'Normal Weight',
                '${categories['Normal Weight']![0]} - ${categories['Overweight']![0]}',
                Colors.green),
            _buildBMICategory(
                'Overweight',
                '${categories['Overweight']![0]} - ${categories['Obese']![0]}',
                Colors.orange),
            _buildBMICategory(
                'Obese', '≥ ${categories['Obese']![0]}', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICategory(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(range,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomRuler extends StatefulWidget {
  final String label;
  final double value;
  final double minValue;
  final double maxValue;
  final String unit;
  final ValueChanged<double> onChanged;

  const CustomRuler({
    super.key,
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    required this.onChanged,
  });

  @override
  State<CustomRuler> createState() => _CustomRulerState();
}

class _CustomRulerState extends State<CustomRuler> {
  late ScrollController _scrollController;
  late double _currentValue;
  final double _itemExtent = 10;
  late int _totalItems;
  bool _isScrolling = false;
  int _lastVibratedTick = -1;
  bool _hasVibrated = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _totalItems = ((widget.maxValue - widget.minValue) / 1).round() + 1;
    _scrollController = ScrollController(
      initialScrollOffset: (_currentValue - widget.minValue) * _itemExtent,
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToValue(_currentValue));

    Vibration.hasVibrator().then((hasVibrator) {
      _hasVibrated = hasVibrator ?? false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToValue(double value) {
    if (!_scrollController.hasClients) return;
    final double newOffset = (value - widget.minValue) * _itemExtent;
    _scrollController.jumpTo(newOffset);
  }

  void _updateValueFromScroll() {
    if (_isScrolling) return;
    final middleOffset = _scrollController.offset + (_itemExtent / 2);
    final newValue = widget.minValue + (middleOffset / _itemExtent).floor();
    if (newValue != _currentValue &&
        newValue >= widget.minValue &&
        newValue <= widget.maxValue) {
      setState(() {
        _currentValue = newValue.toDouble();
      });
      widget.onChanged(_currentValue);
    }
  }

  void _snapToNearestTick() {
    if (_isScrolling) return;
    _isScrolling = true;
    final middleOffset = _scrollController.offset + (_itemExtent / 2);
    final nearestValue =
        (middleOffset / _itemExtent).floor() + widget.minValue.toInt();
    final clampedValue =
        nearestValue.toDouble().clamp(widget.minValue, widget.maxValue);

    final targetOffset = (clampedValue - widget.minValue) * _itemExtent;

    _scrollController
        .animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutQuad,
    )
        .then((_) {
      _isScrolling = false;
      _updateValueFromScroll();
    });
  }

  void _vibrateForTick(int tick) async {
    if (_hasVibrated && tick != _lastVibratedTick) {
      Vibration.vibrate(duration: 1, amplitude: 64);
      _lastVibratedTick = tick;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentValue.toStringAsFixed(0),
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.unit,
                  style: TextStyle(
                      fontSize: 24, color: Theme.of(context).hintColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final halfWidth = constraints.maxWidth / 2;
                return Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollUpdateNotification) {
                          _updateValueFromScroll();
                          int currentTick = _currentValue.round();
                          _vibrateForTick(currentTick);
                        } else if (scrollNotification
                            is ScrollEndNotification) {
                          _snapToNearestTick();
                        }
                        return true;
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            SizedBox(width: halfWidth - _itemExtent / 2),
                            ...List.generate(_totalItems, (index) {
                              final value = widget.minValue + index;
                              return CustomPaint(
                                size: Size(_itemExtent, 60),
                                painter: _RulerPainter(
                                  value: value,
                                  isMajorTick: value % 10 == 0,
                                  isSelected: value == _currentValue,
                                  selectedColor: Theme.of(context).primaryColor,
                                ),
                              );
                            }),
                            SizedBox(width: halfWidth - _itemExtent / 2),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double value;
  final bool isMajorTick;
  final bool isSelected;
  final Color selectedColor;

  _RulerPainter({
    required this.value,
    required this.isMajorTick,
    required this.isSelected,
    this.selectedColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? selectedColor : Colors.grey
      ..strokeWidth = isSelected ? 2 : 1;

    final tickHeight = isMajorTick ? size.height * 0.65 : size.height * 0.4;
    final startY = size.height - tickHeight;

    canvas.drawLine(
      Offset(size.width / 2, startY),
      Offset(size.width / 2, size.height),
      paint,
    );

    if (isMajorTick) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(0),
          style: TextStyle(
            color: isSelected ? selectedColor : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width / 2 - textPainter.width / 2, 0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      value != oldDelegate.value ||
      isMajorTick != oldDelegate.isMajorTick ||
      isSelected != oldDelegate.isSelected;
}
