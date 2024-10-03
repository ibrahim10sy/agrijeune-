import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Campagne.dart';
import 'package:path/path.dart';

class CampagneService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Campagne';

  List<Campagne> campagneList = [];

  Future<void> addCampagne(
      {
      required String nomCampagne,
      required String description,
      required Acteur acteur,
     }) async {
    var addCampagnes = jsonEncode({
      'idCampagne': null,
      'nomCampagne': nomCampagne,
      'description': description,
      'acteur': acteur.toMap()
    });

    final response = await http.post(Uri.parse("$baseUrl/addCampagne"),
        headers: {'Content-Type': 'application/json'}, body: addCampagnes);
    debugPrint(addCampagnes.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

   Future<void> updateCampagne({
    required String idCampagne,
    required String nomCampagne,
    required String description,
  }) async {
    var addCampagnes = jsonEncode({
      'idCampagne': idCampagne,
      'nomCampagne': nomCampagne,
      'description': description,
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idCampagne"),
        headers: {'Content-Type': 'application/json'}, body: addCampagnes);
    debugPrint(addCampagnes.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Campagne>> fetchCampagne() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllCampagne'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      campagneList = body.map((item) => Campagne.fromMap(item)).toList();
      debugPrint(response.body);
      return campagneList;
    } else { 
      campagneList = [];
      print('Échec de la requête campagne avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }
  Future<List<Campagne>> fetchCampagneByActeur(String idActeur) async {
    final response = await http.get(Uri.parse('$baseUrl/getAllCampagneByActeur/$idActeur'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      campagneList = body.map((item) => Campagne.fromMap(item)).toList();
      debugPrint(response.body);
      return campagneList;
    } else {
      campagneList = [];
      print('Échec de la requête cp acteur avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteCampagne(String idCampagne) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idCampagne"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerCampagne(String idCampagne) async {
    final response =
        await http.post(Uri.parse("$baseUrl/activer/$idCampagne"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverCampagne(String idCampagne) async {
    final response =
        await http.post(Uri.parse("$baseUrl/desactiver/$idCampagne"));
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
