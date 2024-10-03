import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';
import 'package:koumi/models/Continent.dart';


class ContinentService extends ChangeNotifier {

    static const String baseUrl = '$apiOnlineUrl/continent';

  List<Continent> continentListe = [];

  Future<void> addContinent({
      required String nomContinent,
      required String descriptionContinent,
      }) async {
    var addcontinents = jsonEncode({
      'idContinent': null,
      'nomContinent': nomContinent,
      'descriptionContinent': descriptionContinent,
    });

    final response = await http.post(Uri.parse("$baseUrl/create"),
        headers: {'Content-Type': 'application/json'}, body: addcontinents);
    debugPrint(addcontinents.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateContinent({
    required String idContinent,
    required String nomContinent,
    required String descriptionContinent,
  }) async {
    var addcontinents = jsonEncode({
      'idContinent': idContinent,
      'nomContinent': nomContinent,
      'descriptionContinent': descriptionContinent,
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idContinent"),
        headers: {'Content-Type': 'application/json'}, body: addcontinents);
    // debugPrint(addcontinents.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Continent>> fetchContinent() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      continentListe = body.map((item) => Continent.fromMap(item)).toList();
      debugPrint(response.body);
      return continentListe;
    } else {
      continentListe = [];
      print('Échec de la requête cont avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteContinent(String idContinent) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idContinent"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerContinent(String idContinent) async {
    final response =
        await http.put(Uri.parse("$baseUrl/activer/$idContinent"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverContinent(String idContinent) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idContinent"));
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