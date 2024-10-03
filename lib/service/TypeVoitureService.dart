import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeVoiture.dart';

class TypeVoitureService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/TypeVoiture';

  List<TypeVoiture> typeList = [];

  Future<void> addTypeVoiture({
    required String nom,
    required String nombreSieges,
    required String description,
    required Acteur acteur,
  }) async {
    var addType = jsonEncode({
      'idTypeVoiture': null,
      'nom': nom,
      'nombreSieges': int.tryParse(nombreSieges),
      'description': description,
      'acteur': acteur.toMap()
    });

    print(addType.toString());
    final response = await http.post(Uri.parse("$baseUrl/create"),
        headers: {'Content-Type': 'application/json'}, body: addType);
    print(response.body.toString());
    print(addType.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<void> updateTypeVoiture({
    required String idTypeVoiture,
    required String nom,
    required String? nombreSieges,
    required String description,
    required Acteur acteur,
  }) async {
    var addType = jsonEncode({
      'idTypeVoiture': idTypeVoiture,
      'nom': nom,
      'nombreSieges': int.tryParse(nombreSieges!),
      'description': description,
      'acteur': acteur.toMap()
    });

    final response = await http.put(Uri.parse("$baseUrl/update/$idTypeVoiture"),
        headers: {'Content-Type': 'application/json'}, body: addType);
    debugPrint(addType.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

  Future<List<TypeVoiture>> fetchTypeVoiture() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      typeList = body.map((item) => TypeVoiture.fromMap(item)).toList();
      debugPrint(response.body);
      return typeList;
    } else {
      typeList = [];
      print('Échec de la requête type v avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<List<TypeVoiture>> fetchTypeVoitureByActeur(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/listeByActeur/$id'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      print("body ${body.toString()}");
      typeList = body.map((item) => TypeVoiture.fromMap(item)).toList();
      debugPrint(response.body);
      return typeList;
    } else {
      typeList = [];
      print('Échec de la requête type v ac avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteType(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/delete/$id"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerType(String id) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$id"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverType(String id) async {
    final response = await http.put(Uri.parse("$baseUrl/desactiver/$id"));
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
