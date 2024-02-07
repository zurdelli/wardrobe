import 'package:flutter/material.dart';

/// Provee el usuario al resto de la aplicacion
class LocationProvider extends ChangeNotifier {
  String _currentLocation = "";

  String get currentLocation => _currentLocation;
  set currentLocation(String newValue) {
    _currentLocation = newValue;
    notifyListeners();
  }
}
