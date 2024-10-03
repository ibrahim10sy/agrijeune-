import 'package:flutter/material.dart';


class DetectorPays extends ChangeNotifier {

  String? _detectedCountryCode;
  String? _detectedCountry;

  String? get detectedCountryCode => _detectedCountryCode ?? 'ML';
  String? get detectedCountry => _detectedCountry ?? 'Mali';

  void setDetectedCountryAndCode(String detectedCountry, String detectedCountryCode) {
    _detectedCountry = detectedCountry;
    _detectedCountryCode = detectedCountryCode;
    notifyListeners();
  }

  bool get hasLocation => _detectedCountryCode != null && _detectedCountry != null;
}
