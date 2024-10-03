import 'package:flutter/material.dart';
import 'package:koumi/models/ParametreGeneraux.dart';

class ParametreGenerauxProvider extends ChangeNotifier {
  List<ParametreGeneraux> _parametreList = [];

  // List<ParametreGeneraux>? get parametreList => _parametreList;
  // void setParametreList(List<ParametreGeneraux> newList) {
  //   _parametreList = newList;
  //   print("provider : ${_parametreList.toString()}");
  //   notifyListeners();
  // }
}
