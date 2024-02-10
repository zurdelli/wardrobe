import 'package:flutter/material.dart';

/// Provider of all the fields used in form to add or modify
class ClothesProvider extends ChangeNotifier {
  String _photoAsString = "";
  String _category = "";
  String _brand = "";
  String _store = "";
  String _place = "";
  String _status = "";
  String _size = "";
  String _date = "";
  Color _color = Colors.transparent;

  String get category => _category;
  set category(String newValue) {
    _category = newValue;
    notifyListeners();
  }

  String get photoAsString => _photoAsString;
  set photoAsString(String newValue) {
    _photoAsString = newValue;
    notifyListeners();
  }

  String get store => _store;
  set store(String newValue) {
    _store = newValue;
    notifyListeners();
  }

  String get brand => _brand;
  set brand(String newValue) {
    _brand = newValue;
    notifyListeners();
  }

  String get place => _place;
  set place(String newValue) {
    _place = newValue;
    notifyListeners();
  }

  String get status => _status;
  set status(String newValue) {
    _status = newValue;
    notifyListeners();
  }

  String get size => _size;
  set size(String newValue) {
    _size = newValue;
    notifyListeners();
  }

  String get date => _date;
  set date(String newValue) {
    _date = newValue;
    notifyListeners();
  }

  Color get color => _color;
  set color(Color newValue) {
    _color = newValue;
    notifyListeners();
  }
}
