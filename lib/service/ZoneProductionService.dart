import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/ZoneProduction.dart';
import 'package:path/path.dart';

class ZoneProductionService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/ZoneProduction';


  List<ZoneProduction> zoneList = [];

  Future<void> addZone({
    required String nomZoneProduction,
    required String latitude,
    required String longitude,
    File? photoZone,
    required Acteur acteur,
  }) async {
    try {
      var requete = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/addZoneProduction'));

      if (photoZone != null) {
        requete.files.add(http.MultipartFile(
            'image', photoZone.readAsBytes().asStream(), photoZone.lengthSync(),
            filename: basename(photoZone.path)));
      }

      requete.fields['zone'] = jsonEncode({
        'idZoneProduction':null,
        'nomZoneProduction': nomZoneProduction,
        'latitude': latitude,
        'longitude': longitude,
        'photoZone': "",
       'acteur': acteur.toMap()
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint(' service ${donneesResponse.toString()}');
      } else {
        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode } ');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de l\'ajout de zone : $e');
    }
  }

   Future<void> updateZone({
    required String idZoneProduction,
    required String nomZoneProduction,
    required String latitude,
    required String longitude,
    required String personneModif,
    File? photoZone,
  }) async {
    try {
      var requete = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl/updateZoneProduction/$idZoneProduction'));

      if (photoZone != null) {
        requete.files.add(http.MultipartFile(
            'image', photoZone.readAsBytes().asStream(), photoZone.lengthSync(),
            filename: basename(photoZone.path)));
      }

      requete.fields['zone'] = jsonEncode({
        'idZoneProduction': idZoneProduction,
        'nomZoneProduction': nomZoneProduction,
        'latitude': latitude,
        'longitude': longitude,
        'photoZone': "",
        'personneModif': personneModif
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('acteur service ${donneesResponse.toString()}');
      } else {
        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de la modification de zone : $e');
    }
  }

  Future<List<ZoneProduction>> fetchZone() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getAllZone'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Fetching data");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        zoneList = body.map((e) => ZoneProduction.fromMap(e)).toList();
        debugPrint(zoneList.toString());
        return zoneList;
      } else {
        zoneList = [];
        print(
            'Échec de la requête  zone avec le code d\'état: ${response.statusCode}');
        throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<List<ZoneProduction>> fetchZoneByActeur(String idActeur) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getAllZonesByActeurs/$idActeur'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Fetching data");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        zoneList = body.map((e) => ZoneProduction.fromMap(e)).toList();
        debugPrint(zoneList.toString());
        return zoneList;
      } else {
        zoneList = [];
        print(
            'Échec de la requête zone ac  avec le code d\'état: ${response.statusCode}');
        throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future deleteZone(String idZone) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/deleteZones/$idZone'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future activerZone(String idZone) async {
    final response = await http.put(Uri.parse('$baseUrl/activer/$idZone'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future desactiverZone(String idZone) async {
    final response = await http.put(Uri.parse('$baseUrl/desactiver/$idZone'));

    if (response.statusCode == 200 || response.statusCode == 201) {
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
