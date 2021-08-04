import 'package:flutter/material.dart';

class FontSizeController with ChangeNotifier {

  double _value = 0;
  double _baseTextScaleFactor;

  double get value => _value;
  double get baseTextScaleFactor => _baseTextScaleFactor;

  void increment() {
    _value = _value + 0.1;
    notifyListeners();
  }

  void decrement() {
    _value = _value - 0.1;
    notifyListeners();
  }

  void set(double val) {
    _value = val;
    notifyListeners();
  }

  void setBaseTextScaleFactor(double val) {
    _baseTextScaleFactor = val;
  }

  void reset() {
    _value = 0;
    notifyListeners();
  }

}