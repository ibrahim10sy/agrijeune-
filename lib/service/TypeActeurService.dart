import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:path/path.dart';

class TypeActeurService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/typeActeur';

  List<TypeActeur> typeList = [];

  Future<void> addTypeActeur({
    required String libelle,
    required String descriptionTypeActeur,
  }) async {
    var addType = jsonEncode({
      'idTypeActeur': null,
      'libelle': libelle,
      'descriptionTypeActeur': descriptionTypeActeur
    });

    final response = await http.post(Uri.parse("$baseUrl/create"),
        headers: {'Content-Type': 'application/json'}, body: addType);
    debugPrint(addType.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateTypeActeur({
    required String idTypeActeur,
    required String libelle,
    required String descriptionTypeActeur,
  }) async {
    var addType = jsonEncode({
      'idTypeActeur': idTypeActeur,
      'libelle': libelle,
      'descriptionTypeActeur': descriptionTypeActeur
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idTypeActeur"),
        headers: {'Content-Type': 'application/json'}, body: addType);
    debugPrint(addType.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<TypeActeur>> fetchTypeActeur() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));

    if (response.statusCode == 200) {
      Duration(seconds: 5);
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      typeList = body.map((item) => TypeActeur.fromMap(item)).toList();
      debugPrint(response.body);
      return typeList;
    } else {
      typeList = [];
      print('Échec de la requête type ac avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteTypeActeur(String idTypeActeur) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idTypeActeur"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerTypeActeur(String idTypeActeur) async {
    final response =
        await http.put(Uri.parse("$baseUrl/activer/$idTypeActeur"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverTypeActeur(String idTypeActeur) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idTypeActeur"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  void applyChange() {
    notifyListeners();
  }
}
