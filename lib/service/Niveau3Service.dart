import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/Niveau2Pays.dart';

import 'package:koumi/constants.dart';

class Niveau3Service extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/nivveau3Pays';

  List<Niveau3Pays> niveauList = [];

  Future<void> addNiveau3Pays({
    required String nomN3,
    required String descriptionN3,
    required Niveau2Pays niveau2Pays,
  }) async {
    var addPays = jsonEncode({
      'idNiveau3Pays': null,
      'nomN3': nomN3,
      'descriptionN3': descriptionN3,
      'niveau2Pays': niveau2Pays.toMap()
    });

    final response = await http.post(Uri.parse("$baseUrl/create"),
        headers: {'Content-Type': 'application/json'}, body: addPays);
    debugPrint(addPays.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateNiveau3Pays({
    required String idNiveau3Pays,
    required String nomN3,
    required String descriptionN3,
    required Niveau2Pays niveau2Pays,
  }) async {
    var addPays = jsonEncode({
      'idNiveau3Pays': idNiveau3Pays,
      'nomN3': nomN3,
      'descriptionN3': descriptionN3,
      'niveau2Pays': niveau2Pays.toMap()
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idNiveau3Pays"),
        headers: {'Content-Type': 'application/json'}, body: addPays);
    debugPrint(addPays.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Niveau3Pays>> fetchNiveau3Pays() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("body N3: ${body.toString()}");
      niveauList = body.map((item) => Niveau3Pays.fromMap(item)).toList();
      debugPrint(response.body);
      return niveauList;
    } else {
      niveauList = [];
      print('Échec de la requête n3 avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<List<Niveau3Pays>> fetchNiveau3ByNiveau2(String idNiveau2Pays) async {
    final response = await http.get(
        Uri.parse('$baseUrl/listeNiveau3PaysByIdNiveau2Pays/$idNiveau2Pays'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      niveauList = body.map((item) => Niveau3Pays.fromMap(item)).toList();
      debugPrint(response.body);
      return niveauList;
    } else {
      niveauList = [];
      print('Échec de la requête fetch n3 by pays avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteNiveau3Pays(String idNiveau3Pays) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idNiveau3Pays"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerNiveau3(String idNiveau3Pays) async {
    final response =
        await http.put(Uri.parse("$baseUrl/activer/$idNiveau3Pays"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverNiveau3Pays(String idNiveau3Pays) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idNiveau3Pays"));
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
