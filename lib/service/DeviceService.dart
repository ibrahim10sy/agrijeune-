import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';
import 'package:koumi/models/Device.dart';

class DeviceService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Device';

  List<Device> deviceList = [];

  Future<List<Device>> fetchDeviceByIdMonnaie(String idMonnaie) async {
    final response = await http
        .get(Uri.parse('$baseUrl/getDeviseByMonnaie/$idMonnaie'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      deviceList = body.map((item) => Device.fromMap(item)).toList();
      debugPrint(response.body);
      return deviceList;
    } else {
      print('Échec de la requête fetch device avec le code d\'état: ${response.statusCode}');
      return deviceList = [];
      // throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  void applyChange() {
    notifyListeners();
  }
}
