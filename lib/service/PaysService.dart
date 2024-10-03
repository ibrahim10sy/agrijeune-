import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/SousRegion.dart';
import 'package:path/path.dart';


class PaysService extends ChangeNotifier {

  static const String baseUrl = '$apiOnlineUrl/pays';

   List<Pays> paysList = [];

  Future<void> addPays({
    required String nomPays,
    required String descriptionPays,
    required String libelleNiveau1Pays,
    required String libelleNiveau2Pays,
    required String libelleNiveau3Pays,

    required String monnaie,
    required String whattsAppPays,
    required SousRegion sousRegion,
  }) async {
    var addPays = jsonEncode({
      'idPays': null,
      'nomPays': nomPays,
      'descriptionPays': descriptionPays,
      'libelleNiveau1Pays': libelleNiveau1Pays,
      'libelleNiveau2Pays': libelleNiveau2Pays,
      'libelleNiveau3Pays': libelleNiveau3Pays,
      'monnaie': monnaie,
      'whattsAppPays': whattsAppPays,
      'sousRegion': sousRegion.toMap()
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

  Future<void> updatePays({
    required String idPays,
    required String nomPays,
    required String descriptionPays,
    required String libelleNiveau1Pays,
    required String libelleNiveau2Pays,
    required String libelleNiveau3Pays,
    required String monnaie,
    required String whattsAppPays,
    required SousRegion sousRegion,
  }) async {
    var addPays = jsonEncode({
      'idPays': idPays,
      'nomPays': nomPays,
      'descriptionPays': descriptionPays,
      'libelleNiveau1Pays': libelleNiveau1Pays,
      'libelleNiveau2Pays': libelleNiveau2Pays,
      'libelleNiveau3Pays': libelleNiveau3Pays,
      'monnaie': monnaie,
      'whattsAppPays': whattsAppPays,
      'sousRegion': sousRegion.toMap()
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idPays"),
        headers: {'Content-Type': 'application/json'}, body: addPays);
    debugPrint(addPays.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Pays>> fetchPays() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      paysList = body.map((item) => Pays.fromMap(item)).toList();
      debugPrint(response.body);
      return paysList;
    } else {
      paysList = [];
      print('Échec de la requête pays avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

   Future<String> getLibelleNiveau3PaysByActor(String id) async {
    final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau3Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response.body;  // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau3Pays');
    }
}

   Future<String> getLibelleNiveau2PaysByActor(String id) async {
    final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau2Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response.body;  // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau3Pays');
    }
}

   Future<String> getLibelleNiveau1PaysByActor(String id) async {
    final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau1Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response.body;  // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau3Pays');
    }
  }

  Future<List<Pays>> fetchPaysBySousRegion(String idSousRegion) async {
    final response = await http.get(Uri.parse('$baseUrl/listePaysBySousRegion/$idSousRegion'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      paysList = body.map((item) => Pays.fromMap(item)).toList();
      debugPrint(response.body);
      return paysList;
    } else {
      paysList = [];
      print('Échec de la requête pays sous avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deletePays(String idPays) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idPays"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerPays(String idPays) async {
    final response =
        await http.put(Uri.parse("$baseUrl/activer/$idPays"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverPays(String idPays) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idPays"));
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