import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Continent.dart';
import 'package:koumi/models/SousRegion.dart';
import 'package:path/path.dart';


class SousRegionService extends ChangeNotifier {

  static const String baseUrl = '$apiOnlineUrl/sousRegion';

  List<SousRegion> sousRegionList = [];

  Future<void> addSousRegion(
      {required String nomSousRegion,
      required  Continent continent,
      }) async {
    var addSousRegions = jsonEncode({
      'idSousRegion': null,
      'nomSousRegion': nomSousRegion,
      'continent': continent.toMap(),
    });

    final response = await http.post(Uri.parse("$baseUrl/create"),
        headers: {'Content-Type': 'application/json'}, body: addSousRegions);
    debugPrint(addSousRegions.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateSousRegion({
    required String idSousRegion,
    required String nomSousRegion,
    required Continent continent,
  }) async {
    var addSousRegions = jsonEncode({
      'idSousRegion': idSousRegion,
      'nomSousRegion': nomSousRegion,
      'continent': continent.toMap(),
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idSousRegion"),
        headers: {'Content-Type': 'application/json'}, body: addSousRegions);
    debugPrint(addSousRegions.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<SousRegion>> fetchSousRegion() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));

    if (response.statusCode == 200 || response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      sousRegionList = body.map((item) => SousRegion.fromMap(item)).toList();
      debugPrint(response.body);
      return sousRegionList;
    } else {
      sousRegionList = [];
      print('Échec de la requête sous  avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }
  Future<List<SousRegion>> fetchSousRegionByContinent(String idContinent) async {
    final response = await http.get(Uri.parse('$baseUrl/listeSousRegionByContinent/$idContinent'));
      
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      sousRegionList = body.map((item) => SousRegion.fromMap(item)).toList();
      debugPrint(response.body);
      return sousRegionList;
    } else {
      sousRegionList = [];
      print('Échec de la requête sous cont avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteSousRegion(String idSousRegion) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idSousRegion"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerSousRegion(String idSousRegion) async {
    final response =
        await http.put(Uri.parse("$baseUrl/activer/$idSousRegion"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverSousRegion(String idSousRegion) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idSousRegion"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la desactivation avec le code: ${response.statusCode}");
    }
  }

  void applyChange() {
    notifyListeners();
  }

}