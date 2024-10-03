import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';
import 'package:koumi/models/Filiere.dart';

class FiliereService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Filiere';

  List<Filiere> filiereList = [];

  Future<void> addFileres({
    required String libelleFiliere,
    required String descriptionFiliere,
    // required Acteur acteur,
  }) async {
    var addFileress = jsonEncode({
      'idFiliere': null,
      'libelleFiliere': libelleFiliere,
      'descriptionFiliere': descriptionFiliere,
      // 'acteur': acteur.toMap()
    });

    final response = await http.post(Uri.parse("$baseUrl/AddFiliere"),
        headers: {'Content-Type': 'application/json'}, body: addFileress);
    // debugPrint(addFileress.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  } 

  Future<void> updatesFileres({
    required String idFiliere,
    required String libelleFiliere,
    required String descriptionFiliere,
    required String personneModif,
  }) async {
    var addFileress = jsonEncode({
      'idFiliere': idFiliere,
      'libelleFiliere': libelleFiliere,
      'descriptionFiliere': descriptionFiliere,
      'personneModif': personneModif
    });

    final response = await http.put(
        Uri.parse("$baseUrl/updateFilieres/$idFiliere"),
        headers: {'Content-Type': 'application/json'},
        body: addFileress);
    debugPrint(addFileress.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Filiere>> fetchFiliere() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllFiliere/'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      filiereList = body.map((item) => Filiere.fromMap(item)).toList();
      debugPrint(response.body);
      return filiereList;
    } else {
      filiereList = [];
      print('Échec de la requête filiere avec le code d\'état: ${response.statusCode}');
      return  filiereList = [];
      
    }
  }

  Future<List<Filiere>> fetchFiliereByActeur(String idActeur) async {
    final response =
        await http.get(Uri.parse('$baseUrl/filiereByActeur/$idActeur'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      filiereList = body.map((item) => Filiere.fromMap(item)).toList();
      debugPrint(response.body);
      return filiereList;
    } else {
      filiereList = [];
      print('Échec de la requête fil ac avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future getfiliereByActeur(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/filiereByActeur/$id'));
    //print(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Bienvenu au categorie");
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to lire');
    }
  }

  Future<void> deleteFiliere(String idFiliere) async {
    final response = await http.delete(Uri.parse("$baseUrl/delete/$idFiliere"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerFiliere(String idFiliere) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$idFiliere"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverFiliere(String idFiliere) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idFiliere"));
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
