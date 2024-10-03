import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Forme.dart';

class FormeService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/formeproduit';

  List<Forme> formeList = [];

  Future<void> addFormess({
    required String libelleForme,
    required String descriptionForme,
  }) async {
    var addFormes = jsonEncode({
      'idForme': null,
      'libelleForme': libelleForme,
      'descriptionForme': descriptionForme,
  
    });

    final response = await http.post(Uri.parse("$baseUrl/AddForme"),
        headers: {'Content-Type': 'application/json'}, body: addFormes);
    // debugPrint(addFormes.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updatesFormes({
    required String idForme,
    required String libelleForme,
    required String descriptionForme,
  }) async {
    var addFormes = jsonEncode({
      'idForme': idForme,
      'libelleForme': libelleForme,
      'descriptionForme': descriptionForme,
    });

    final response = await http.put(
        Uri.parse("$baseUrl/updateForme/$idForme"),
        headers: {'Content-Type': 'application/json'},
        body: addFormes);
    debugPrint(addFormes.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Forme>> fetchForme() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllForme/'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      formeList = body.map((item) => Forme.fromMap(item)).toList();
      debugPrint(response.body);
      return formeList;
    } else {
      formeList = [];
      print('Échec de la requête forme avec le code d\'état: ${response.statusCode}');
      return formeList = [];
    }
  }

  
  Future<void> deleteForme(String idForme) async {
    final response = await http.delete(Uri.parse("$baseUrl/delete/$idForme"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerForme(String idForme) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$idForme"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverForme(String idForme) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idForme"));
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
