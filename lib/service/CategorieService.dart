import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Filiere.dart';

class CategorieService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Categorie';

  List<CategorieProduit> categorieList = [];

  Future<void> addCategorie({
    required String libelleCategorie,
    required String descriptionCategorie,
    required Filiere filiere,
    // required Acteur acteur,
  }) async {
    var addcat = jsonEncode({
      'idCategorieProduit': null,
      'libelleCategorie': libelleCategorie,
      'descriptionCategorie': descriptionCategorie,
      'filiere': filiere.toMap(),
      // 'acteur': acteur.toMap()
    });

    final response = await http.post(Uri.parse("$baseUrl/addCategorie"),
        headers: {'Content-Type': 'application/json'}, body: addcat);
    // debugPrint(addFileress.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateCategorie({
    required String idCategorieProduit,
    required String libelleCategorie,
    required String descriptionCategorie,
    required String personneModif,
    required Filiere filiere,
  }) async {
    var addcat = jsonEncode({
      'idCategorieProduit': idCategorieProduit,
      'libelleCategorie': libelleCategorie,
      'descriptionCategorie': descriptionCategorie,
      'personneModif': personneModif,
      'filiere': filiere.toMap(),
    });

    final response = await http.put(
        Uri.parse("$baseUrl/update/$idCategorieProduit"),
        headers: {'Content-Type': 'application/json'},
        body: addcat);
    // debugPrint(addFileress.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<CategorieProduit>> fetchCategorie() async {
    final response = await http.get(Uri.parse("$baseUrl/allCategorie"));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      categorieList =
          body.map((item) => CategorieProduit.fromMap(item)).toList();
      debugPrint(response.body);
      return categorieList;
    } else {
      
      print('Échec de la requête categorie avec le code d\'état: ${response.statusCode}');
      return categorieList = [];
    }
  }

 Future<List<CategorieProduit>> fetchSearchItems() async {
    final response = await http.get(Uri.parse("$baseUrl/allCategorie"));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("Body : ${response.body.toString()}");
      categorieList =
          body.map((item) => CategorieProduit.fromMap(item)).toList();
      debugPrint(response.body);
      return categorieList;
    } else {
      print(
          'Échec de la requête fetch all cat avec le code d\'état: ${response.statusCode}');
      return categorieList = [];
    }
  }

  Future<List<CategorieProduit>> fetchCategorieByFiliere(
      String idFiliere) async {
    final response =
        await http.get(Uri.parse('$baseUrl/allCategorieByFiliere/$idFiliere'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      categorieList =
          body.map((item) => CategorieProduit.fromMap(item)).toList();
      debugPrint(response.body);
      return categorieList;
    } else {
      categorieList = [];
      print('Échec de la requête cat filiere avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteCategorie(String idCategorie) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idCategorie"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerCategorie(String idCategorie) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$idCategorie"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverCategorie(String idCategorie) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idCategorie"));
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
