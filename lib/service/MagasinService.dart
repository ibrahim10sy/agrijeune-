import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Magasin.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:path/path.dart';

class MagasinService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Magasin';
  List<Magasin> magasin = [];
  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;

  Future<void> creerMagasin(
      {required String nomMagasin,
      required String contactMagasin,
      required String localiteMagasin,
      required String pays,
      File? photo,
      required Acteur acteur,
      required Niveau1Pays niveau1Pays}) async {
    try {
      
      var requete =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/addMagasin'));

      if (photo != null) {
        requete.files.add(http.MultipartFile(
            'image', photo.readAsBytes().asStream(), photo.lengthSync(),
            filename: basename(photo.path)));
      }

      requete.fields['magasin'] = jsonEncode({
        'nomMagasin': nomMagasin,
        'contactMagasin': contactMagasin,
        'localiteMagasin': localiteMagasin,
        'pays': pays,
        'photo': "",
        'acteur': acteur.toMap(),
        'niveau1Pays': niveau1Pays.toMap()
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('magasin service ${donneesResponse.toString()}');
      } else {
        final errorMessage =
            json.decode(utf8.decode(responsed.bodyBytes))['message'];
        throw Exception(' ${errorMessage}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de l\'ajout du magasin : $e');
    }
  }

  Future<void> updateMagasin({
    required String idMagasin,
    required String nomMagasin,
    required String contactMagasin,
    required String localiteMagasin,
    File? photo,
    required Acteur acteur,
    required Niveau1Pays niveau1Pays,
  }) async {
    try {
      var requete =
          http.MultipartRequest('PUT', Uri.parse('$baseUrl/update/$idMagasin'));

      if (photo != null) {
        requete.files.add(http.MultipartFile(
            'image', photo.readAsBytes().asStream(), photo.lengthSync(),
            filename: basename(photo.path)));
      }

      requete.fields['magasin'] = jsonEncode({
        'idMagasin': idMagasin,
        'nomMagasin': nomMagasin,
        'contactMagasin': contactMagasin,
        'localiteMagasin': localiteMagasin,
        'photo': "",
        'acteur': acteur.toMap(),
        'niveau1Pays': niveau1Pays.toMap()
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('magasin service ${donneesResponse.toString()}');
      } else {
        final errorMessage =
            json.decode(utf8.decode(responsed.bodyBytes))['message'];
        throw Exception(' ${errorMessage}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de l\'ajout du magasin : $e');
    }
  }

  Future<List<Magasin>> fetchSearchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/getAllMagagin'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("Body : ${response.body.toString()}");
      magasin = body.map((item) => Magasin.fromMap(item)).toList();
      debugPrint(response.body);
      return magasin;
    } else {
      print(
          'Échec de la requête fetch all mag avec le code d\'état: ${response.statusCode}');
      return magasin = [];
    }
  }

  Future<List<Magasin>> fetchMagasinByActeur(String idMagasin,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      magasin.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Magasin/getAllMagasinsByActeurWithPagination?idActeur=$idMagasin&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Magasin> newMagasin =
              body.map((e) => Magasin.fromMap(e)).toList();
          magasin.addAll(newMagasin);
        }

        debugPrint(
            "response body all magasin by acteur with pagination ${page} par défilement soit ${magasin.length}");
      } else {
        print(
            'Échec de la requête  mag avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des magasins: $e');
    } finally {
      isLoading = false;
    }
    return magasin;
  }

  Future<List<Magasin>> fetchMagasinByNiveau1PaysWithPagination(
      String idNiveau1Pays,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      magasin.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Magasin/getAllMagasinByNiveau1PaysWithPagination?idNiveau1Pays=$idNiveau1Pays&page=${page}&size=${size}'));
      debugPrint(
          '$apiOnlineUrl/Magasin/getAllMagasinByNiveau1PaysWithPagination?idNiveau1Pays=$idNiveau1Pays&page=${page}&size=${size}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Magasin> newMagasin =
              body.map((e) => Magasin.fromMap(e)).toList();
          magasin.addAll(newMagasin);
        }

        debugPrint(
            "response body all magasin by niveau 1 pays with pagination ${page} par défilement soit ${magasin.length}");
      } else {
        print(
            'Échec de la requête  mag niavec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des magasins: $e');
    } finally {
      isLoading = false;
    }
    return magasin;
  }

  Future<List<Magasin>> fetchAllMagasin({bool refresh = false}) async {
    isLoading = true;

    if (refresh) {
      magasin.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Magasin/getAllMagasinWithPagination?page=${page}&size=${size}'));
      print(
          '$apiOnlineUrl/Magasin/getAllMagasinWithPagination?page=${page}&size=${size}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Magasin> newMagasin =
              body.map((e) => Magasin.fromMap(e)).toList();
          magasin.addAll(newMagasin);
        }

        debugPrint(
            "response body all magasin  with pagination ${page} par défilement soit ${magasin.length}");
      } else {
        print(
            'Échec de la requête mag pagavec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des magasins: $e');
    } finally {
      isLoading = false;
    }
    return magasin;
  }

  Future<List<Magasin>> fetchMagasinByRegion(String id) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/getAllMagasinByPays/${id}'));
      if (response.statusCode == 200) {
        // final String jsonString = utf8.decode(response.bodyBytes);
        //       List<dynamic> data = json.decode(jsonString);
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        magasin = body
            .where((magasin) => magasin['statutMagasin'] == true)
            .map((e) => Magasin.fromMap(e))
            .toList();
        // magasin = data.map((item) => Magasin.fromMap(item)).toList();
        return magasin;
      } else {
        print('Failed to load magasins for region $id');
        return magasin = [];
      }
    } catch (e) {
      print('Error fetching magasins for region $id: $e');
    }
    return magasin = [];
  }

  Future<List<Magasin>> fetchMagasinByRegionAndActeur(
      String idActeur, String idNiveau1Pays) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/getAllMagasinByActeurAndNiveau1Pays/${idActeur}/${idNiveau1Pays}'));
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        // final String jsonString = utf8.decode(response.bodyBytes);
        //       List<dynamic> data = json.decode(jsonString);
        print("Fetching data succès ${idActeur} / ${idNiveau1Pays}");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        magasin = body.map((e) => Magasin.fromMap(e)).toList();
        debugPrint(
            "Succes : idActeur : $idActeur , idNiveau1Pays : $idNiveau1Pays , : liste ${magasin.toString()}");
        return magasin;
      } else {
        print(
            'Failed to load magasins for region $idNiveau1Pays | and acteur $idActeur');
        return magasin = [];
      }
    } catch (e) {
      print(
          'Error fetching magasins for acteur $idActeur et region $idNiveau1Pays: $e');
      // throw Exception(" erreur catch :  ${e.toString()}");
      return magasin = [];
    }
  }

  Future<void> deleteMagasin(String idMagasin) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete/$idMagasin'));
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerMagasin(String idMagasin) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$idMagasin"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverMagasin(String idMagasin) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idMagasin"));
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
