import 'package:flutter/material.dart';

/// Provee el usuario al resto de la aplicacion
class UserProvider extends ChangeNotifier {
  String _currentUser = "";
  String _currentUserName = "";

  String get currentUserName => _currentUserName;
  set currentUserName(String newValue) {
    _currentUserName = newValue;
    notifyListeners();
  }

  String get currentUser => _currentUser;
  set currentUser(String newValue) {
    _currentUser = newValue;
    notifyListeners();
  }
}
