import 'package:flutter/material.dart';

/// Provider of all the fields used in form to add or modify
class ClothesProvider extends ChangeNotifier {
  String _brand = "";
  Color _color = Colors.transparent;
  String _date = "";
  bool _hasBeenLent = false;
  String _holder = "";
  String _image = "";
  String _imageCache = "";
  String _model = "";
  String _owner = "";
  String _place = "";
  String _storePlace = "";
  String _size = "";
  String _store = "";
  String _sublocation = "";
  String _warranty = "";
  String _website = "";
  String _thumbnail = "";

  int _cantidad = 0;

  String get website => _website;
  set website(String value) {
    _website = value;
    notifyListeners();
  }

  int get cantidad => _cantidad;
  set cantidad(int value) {
    _cantidad = value;
    notifyListeners();
  }

  String get holder => _holder;
  set holder(String value) {
    _holder = value;
    notifyListeners();
  }

  String get owner => _owner;
  set owner(String value) {
    _owner = value;
    notifyListeners();
  }

  String get model => _model;
  set model(String value) {
    _model = value;
    notifyListeners();
  }

  String get warranty => _warranty;
  set warranty(String value) {
    _warranty = value;
    notifyListeners();
  }

  String get sublocation => _sublocation;
  set sublocation(String value) {
    _sublocation = value;
    notifyListeners();
  }

  bool get hasBeenLent => _hasBeenLent;
  set hasBeenLent(bool value) {
    _hasBeenLent = value;
    notifyListeners();
  }

  String get image => _image;
  set image(String newValue) {
    _image = newValue;
    notifyListeners();
  }

  String get thumbnail => _thumbnail;
  set thumbnail(String newValue) {
    _thumbnail = newValue;
    notifyListeners();
  }

  String get imageCache => _imageCache;
  set imageCache(String newValue) {
    _imageCache = newValue;
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

  String get storePlace => _storePlace;
  set storePlace(String newValue) {
    _storePlace = newValue;
    notifyListeners();
  }

  // String get status => _status;
  // set status(String newValue) {
  //   _status = newValue;
  //   notifyListeners();
  // }

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
