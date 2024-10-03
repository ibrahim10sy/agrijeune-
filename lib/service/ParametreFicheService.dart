import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/ParametreFiche.dart';

class ParametreFicheService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/parametreFiche';

  List<ParametreFiche> paramList = [];

  Future<void> addParametre({
    required String classeParametre,
    required String champParametre,
    required String libelleParametre,
    required String typeDonneeParametre,
    required List<String> listeDonneeParametre,
    required String valeurMax,
    required String valeurMin,
    required String valeurObligatoire,
    required String critereChampParametre,
  }) async {
    var addParam = jsonEncode({
      'idParametreFiche': null,
      'classeParametre':classeParametre,
      'champParametre': champParametre,
      'libelleParametre': libelleParametre,
      'typeDonneeParametre': typeDonneeParametre,
      'listeDonneeParametre': listeDonneeParametre.toList(),
      'valeurMax': int.tryParse(valeurMax),
      'valeurMin': int.tryParse(valeurMin),
      'valeurObligatoire': int.tryParse(valeurObligatoire),
      'critereChampParametre': critereChampParametre
    });

    final response = await http.post(Uri.parse("$baseUrl/addParametreFiche"),
        headers: {'Content-Type': 'application/json'}, body: addParam);
    debugPrint(addParam.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateParametre({
    required String idParametreFiche,
    required String classeParametre,
    required String champParametre,
    required String libelleParametre,
    required String typeDonneeParametre,
    required List<String> listeDonneeParametre,
    required String valeurMax,
    required String valeurMin,
    required String valeurObligatoire,
    required String critereChampParametre,
  }) async {
    var addParam = jsonEncode({
      'idParametreFiche': idParametreFiche,
      'champParametre': champParametre,
       'classeParametre': classeParametre,
      'libelleParametre': libelleParametre,
      'typeDonneeParametre': typeDonneeParametre,
      'listeDonneeParametre': listeDonneeParametre.toList(),
      'valeurMax': int.tryParse(valeurMax),
      'valeurMin': int.tryParse(valeurMin),
      'valeurObligatoire': int.tryParse(valeurObligatoire),
      'critereChampParametre': critereChampParametre
    });

    final response = await http.put(
        Uri.parse("$baseUrl/update/$idParametreFiche"),
        headers: {'Content-Type': 'application/json'},
        body: addParam);
    debugPrint(addParam.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<ParametreFiche>> fetchParametre() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getParametreFiche'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Fetching data");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint(body.toString());
        paramList = body.map((e) => ParametreFiche.fromJson(e)).toList();
        debugPrint(paramList.toString());
        return paramList;
      } else {
        paramList = [];
        print(
            'Échec de la requête pa fiche avec le code d\'état: ${response.statusCode}');
        throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future deleteParametre(String idParametre) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/delete/$idParametre'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future activerParametre(String idParametre) async {
    final response = await http.put(Uri.parse('$baseUrl/activer/$idParametre'));

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future desactiverParametre(String idParametre) async {
    final response =
        await http.put(Uri.parse('$baseUrl/desactiver/$idParametre'));

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  void applyChange() {
    notifyListeners();
  }
}
