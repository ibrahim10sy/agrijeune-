import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Campagne.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/Superficie.dart';

class SuperficieService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Superficie';

  List<Superficie> superficieList = [];

  Future<void> addSuperficie(
      {required String localite,
      required String superficieHa,
      required String dateSemi,
      // required String description,
      required Acteur acteur,
      required List<String> intrants,
      required Speculation speculation,
      required Campagne campagne}) async {
    var addSuperficies = jsonEncode({
      'idSuperficie': null,
      'localite': localite,
      'superficieHa': superficieHa,
      //  'description': description,
      'dateSemi': dateSemi,
      'acteur': acteur.toMap(),
      'intrants': intrants,
      'speculation': speculation.toMap(),
      'campagne': campagne.toMap()
    });

    final response = await http.post(Uri.parse("$baseUrl/addSuperficie"),
        headers: {'Content-Type': 'application/json'}, body: addSuperficies);
    debugPrint(addSuperficies.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateSuperficie(
      {required String idSuperficie,
      required String localite,
      required String superficieHa,
      required String dateSemi,
      required String personneModif,
      // required Acteur acteur,
      // required String description,
      required List<String> intrants,
      required Speculation speculation,
      required Campagne campagne}) async {
    var addSuperficies = jsonEncode({
      'idSuperficie': idSuperficie,
      'localite': localite,
      'personneModif': personneModif,
      'superficieHa': superficieHa,
      'dateSemi': dateSemi,
      // 'description': description,
      // 'acteur': acteur.toMap(),
      'intrants': intrants,
      'speculation': speculation.toMap(),
      'campagne': campagne.toMap()
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idSuperficie"),
        headers: {'Content-Type': 'application/json'}, body: addSuperficies);
    debugPrint(addSuperficies.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<Superficie>> fetchSuperficie() async {
    final response = await http.get(Uri.parse('$baseUrl/getSuperficie'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      superficieList = body.map((item) => Superficie.fromMap(item)).toList();
      debugPrint(response.body);
      return superficieList;
    } else {
      superficieList = [];
      print('Échec de la requête all super avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<List<Superficie>> fetchSuperficieByActeur(String idActeur) async {
    final response =
        await http.get(Uri.parse('$baseUrl/getSuperficieByActeur/$idActeur'));
    debugPrint("Response ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      superficieList = body.map((item) => Superficie.fromMap(item)).toList();
      debugPrint("liste ${superficieList.toString()}");
      return superficieList;
    } else {
      superficieList = [];
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<List<Superficie>> fetchSuperficieBySpeculation(
      String idSpeculation) async {
    final response = await http.get(
        Uri.parse('$baseUrl/getAllSuperficieBySpeculation/$idSpeculation'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      superficieList = body.map((item) => Superficie.fromMap(item)).toList();
      debugPrint(response.body);
      return superficieList;
    } else {
      superficieList = [];
      print('Échec de la requête sup ac  avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteSuperficie(String idSuperficie) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idSuperficie"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerSuperficie(String idSuperficie) async {
    final response =
        await http.put(Uri.parse("$baseUrl/activer/$idSuperficie"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverSuperficie(String idSuperficie) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idSuperficie"));
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
