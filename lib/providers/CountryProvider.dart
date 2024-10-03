
import 'package:flutter/material.dart';
import 'package:koumi/service/SharedPrefsService.dart';

class CountryProvider with ChangeNotifier {
  String? _countryCode;
  String? _countryName;
  final SharedPrefsService _prefsService = SharedPrefsService();

  String? get countryCode => _countryCode;
  String? get countryName => _countryName;

  CountryProvider() {
    _loadCountryInfo();
  }

  Future<void> _loadCountryInfo() async {
    _countryCode = await _prefsService.getCountryCode();
    _countryName = await _prefsService.getCountryName();
    notifyListeners();
  }

  Future<void> setCountryInfo(String code, String name) async {
    _countryCode = code;
    _countryName = name;
    await _prefsService.setCountryInfo(code, name);
    notifyListeners();
  }
}