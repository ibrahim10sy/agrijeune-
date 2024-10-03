
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/models/Pays.dart';

class Niveau1Service extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/niveau1Pays';
  // static const String baseUrl = 'http://10.0.2.2:9000/api-koumi/niveau1Pays';

  List<Niveau1Pays> niveauList = [];

  Future<void> addNiveau1Pays({
    required String nomN1,
    required String descriptionN1,
    required Pays pays,
  }) async {
    var addPays = jsonEncode({
      'idNiveau1Pays': null,
      'nomN1': nomN1,
      'descriptionN1': descriptionN1,
      'pays': pays.toMap()
    });

    final response = await http.post(Uri.parse("$baseUrl/create"),
        headers: {'Content-Type': 'application/json'}, body: addPays);
    // debugPrint(addPays.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
      
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateNiveau1Pays({
    required String idNiveau1Pays,
    required String nomN1,
    required String descriptionN1,
    required Pays pays,
  }) async {
    var addPays = jsonEncode({
      'idNiveau1Pays': idNiveau1Pays,
      'nomN1': nomN1,
      'descriptionN1': descriptionN1,
      'pays': pays.toMap()
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idNiveau1Pays"),
        headers: {'Content-Type': 'application/json'}, body: addPays);
    debugPrint(addPays.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
      applyChange();
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Niveau1Pays>> fetchNiveau1Pays() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      niveauList = body.map((item) => Niveau1Pays.fromMap(item)).toList();
      debugPrint(response.body);
      return niveauList;
    } else {
      niveauList = [];
      print('Échec de la requête nive avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<List<Niveau1Pays>> fetchNiveau1ByPays(String idPays) async {
    final response = await http
        .get(Uri.parse('$baseUrl/listeNiveau1PaysByIdPays/$idPays'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      niveauList = body.map((item) => Niveau1Pays.fromMap(item)).toList();
      debugPrint(response.body);
      return niveauList;
    } else {
      niveauList = [];
      print('Échec de la requête fetch n1 by pays avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteNiveau1Pays(String idNiveau1Pays) async {
    final response = await http.delete(Uri.parse("$baseUrl/delete/$idNiveau1Pays"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerNiveau1(String idNiveau1Pays) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$idNiveau1Pays"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverNiveau1Pays(String idNiveau1Pays) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idNiveau1Pays"));
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

