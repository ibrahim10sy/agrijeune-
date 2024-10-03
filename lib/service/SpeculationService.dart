import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Speculation.dart';

class SpeculationService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Speculation';

  List<Speculation> speculationList = [];

  Future<void> addSpeculation({
    required String nomSpeculation,
    required String descriptionSpeculation,
    required CategorieProduit categorieProduit,

  }) async {
    var addSpeculations = jsonEncode({
      'idSpeculation': null,
      'nomSpeculation': nomSpeculation,
      'descriptionSpeculation': descriptionSpeculation,
      'categorieProduit': categorieProduit.toMap(),
    });

    final response = await http.post(Uri.parse("$baseUrl/addSpeculation"),
        headers: {'Content-Type': 'application/json'}, body: addSpeculations);
    debugPrint(addSpeculations.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateSpeculation({
    required String idSpeculation,
    required String nomSpeculation,
    required String descriptionSpeculation,
  }) async {
    var addSpeculations = jsonEncode({
      'idSpeculation': idSpeculation,
      'nomSpeculation': nomSpeculation,
      'descriptionSpeculation': descriptionSpeculation,
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idSpeculation"),
        headers: {'Content-Type': 'application/json'}, body: addSpeculations);
    debugPrint(addSpeculations.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
      applyChange();
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Speculation>> fetchSpeculation() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllSpeculation'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      speculationList = body.map((item) => Speculation.fromMap(item)).toList();
      debugPrint(response.body);
      return speculationList;
    } else {
      speculationList = [];
      print('Échec de la requête specu avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<List<Speculation>> fetchSpeculationByActeur(String idActeur) async {
    final response = await http
        .get(Uri.parse('$baseUrl/getAllSpeculationByActeur/$idActeur'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      speculationList = body.map((item) => Speculation.fromMap(item)).toList();
      debugPrint(response.body);
      return speculationList;
    } else {
      speculationList = [];
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<List<Speculation>> fetchSpeculationByCategorie(
      String idSpeculation) async {
    final response = await http
        .get(Uri.parse('$baseUrl/getAllSpeculationByCategorie/$idSpeculation'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      speculationList = body.map((item) => Speculation.fromMap(item)).toList();
      debugPrint(response.body);
      return speculationList;
    } else {
      speculationList = [];
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteSpeculation(String idSpeculation) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/deleteSpeculation/$idSpeculation"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerSpeculation(String idSpeculation) async {
    final response =
        await http.put(Uri.parse("$baseUrl/activer/$idSpeculation"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverSpeculation(String idSpeculation) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idSpeculation"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();

      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la desactivation avec le code: ${response.statusCode}");
    }
  }

 Future<List<Speculation>> getSpeculationsByCategories(List<String> idsCategorieProduit) async {
  try {
    // String idsJson = jsonEncode(idsCategorieProduit);
    final response = await http.get(Uri.parse('http://api-koumi/Speculation/by-categories/${idsCategorieProduit}'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Speculation> speculations = [];
      data.forEach((speculationJson) {
        speculations.add(Speculation.fromJson(speculationJson));
      });
      debugPrint("Spéculations par catégorie $idsCategorieProduit : $speculations");
      return speculations;
    } else {
      throw Exception('Échec de la récupération des spéculations: ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur lors de la récupération des spéculations : $e');
    throw Exception('Erreur lors de la récupération des spéculations');
  }
}


  void applyChange() {
    notifyListeners();
  }
}
