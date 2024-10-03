import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _countryCodeKey = 'countryCode';
  static const String _countryNameKey = 'countryName';

  Future<void> setCountryInfo(String code, String name) async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getString('countryCode')== null){

    await prefs.setString(_countryCodeKey, code);
    }
    if(prefs.getString('countryName')== null){

    await prefs.setString(_countryNameKey, name);
    }
  }

  Future<String?> getCountryCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_countryCodeKey);
  }

  Future<String?> getCountryName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_countryNameKey);
  }
}
