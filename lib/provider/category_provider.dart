import 'package:flutter/material.dart';

/// Provee el usuario al resto de la aplicacion
class CategoryProvider extends ChangeNotifier {
  String _currentCategory = "";

  String get currentCategory => _currentCategory;

  set currentCategory(String newValue) {
    _currentCategory = newValue;
    notifyListeners();
  }
}
