// import 'package:flutter/material.dart';
// import 'package:koumi_app/models/Pays.dart';
// import 'package:koumi_app/service/PaysService.dart';


// class CountryProvider with ChangeNotifier {
//   PaysService _paysService = PaysService();
//   Pays? _pays;
//   bool _isLoading = false;

//   Pays? get pays => _pays;
//   bool get isLoading => _isLoading;

//   Future<void> fetchCountry(String niveau3PaysActeur) async {
//     _isLoading = true;
//     notifyListeners();

//     // _pays = await _paysService.getCountryByName(niveau3PaysActeur.toLowerCase());

//     _isLoading = false;
//     notifyListeners();
//   }
// }
