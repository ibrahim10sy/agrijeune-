import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Unite.dart';

class UniteService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Unite';

  List<Unite> uniteList = [];

  Future<void> addUnite({
    required String nomUnite,
    required String sigleUnite,
    required String description,
    required Acteur acteur,
  }) async {
    var addUnites = jsonEncode(
        {'idUnite': null, 'nomUnite': nomUnite, 'sigleUnite': sigleUnite, 'description':description,'acteur': acteur.toMap()});

    final response = await http.post(Uri.parse("$baseUrl/addUnite"),
        headers: {'Content-Type': 'application/json'}, body: addUnites);
    debugPrint(addUnites.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateUnite({
    required String idUnite,
    required String nomUnite,
    required String personneModif,
     required String sigleUnite,
    required String description,
    required Acteur acteur,
  }) async {
    var addUnites = jsonEncode({
      'idUnite': idUnite,
      'nomUnite': nomUnite,
      'sigleUnite':sigleUnite,
      'description': description,
      'personneModif': personneModif,
      'acteur': acteur.toMap()
    });

    final response = await http.put(Uri.parse("$baseUrl/updateUnite/$idUnite"),
        headers: {'Content-Type': 'application/json'}, body: addUnites);
    debugPrint(addUnites.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Unite>> fetchUnite() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllUnite'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      uniteList = body.map((item) => Unite.fromMap(item)).toList();
      debugPrint(response.body);
      return uniteList;
    } else {
      uniteList = [];
      print('Échec de la requête  unite avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteUnite(String idUnite) async {
    final response = await http.delete(Uri.parse("$baseUrl/delete/$idUnite"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerUnite(String idUnite) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$idUnite"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverUnite(String idUnite) async {
    final response = await http.put(Uri.parse("$baseUrl/desactiver/$idUnite"));
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
