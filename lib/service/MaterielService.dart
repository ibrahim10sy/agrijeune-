import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Materiels.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeMateriel.dart';
import 'package:path/path.dart';

class MaterielService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/Materiel';

  List<Materiels> materielList = [];
  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;

  Future<void> addMateriel({
    required int prixParHeure,
    required String nom,
    required String description,
    File? photoMateriel,
    required String localisation,
    required String etatMateriel,
    required Acteur acteur,
    required TypeMateriel typeMateriel,
    required Monnaie monnaie,
    Speculation? speculation,
  }) async {
    try {
      var requete =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/addMateriel'));

      if (photoMateriel != null) {
        requete.files.add(http.MultipartFile('image',
            photoMateriel.readAsBytes().asStream(), photoMateriel.lengthSync(),
            filename: basename(photoMateriel.path)));
      }

      requete.fields['materiel'] = jsonEncode({
        'prixParHeure': prixParHeure,
        'nom': nom,
        'description': description,
        'photoMateriel': "",
        'localisation': localisation,
        'etatMateriel': etatMateriel,
        'acteur': acteur.toMap(),
        'typeMateriel': typeMateriel.toMap(),
        'monnaie': monnaie.toMap(),
        if (speculation != null) 'speculation': speculation.toMap(),
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('materiel service ${donneesResponse.toString()}');
        debugPrint('nom ${donneesResponse['nom']}');
      } else {
        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de l\'ajout de acteur : $e');
    }
  }

  Future<void> updateMateriel(
      {required String idMateriel,
      required int prixParHeure,
      required String nom,
      required String description,
      File? photoMateriel,
      required String localisation,
      required String etatMateriel,
      required Acteur acteur,
      required TypeMateriel typeMateriel,
      required Monnaie monnaie}) async {
    try {
      var requete = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl/update/$idMateriel'));

      if (photoMateriel != null) {
        requete.files.add(http.MultipartFile('image',
            photoMateriel.readAsBytes().asStream(), photoMateriel.lengthSync(),
            filename: basename(photoMateriel.path)));
      }

      requete.fields['materiel'] = jsonEncode({
        'idMateriel': idMateriel,
        'prixParHeure': prixParHeure,
        'nom': nom,
        'description': description,
        'photoMateriel': "",
        'localisation': localisation,
        'etatMateriel': etatMateriel,
        'acteur': acteur.toMap(),
        'typeMateriel': typeMateriel.toMap(),
        'monnaie': monnaie.toMap()
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('intrant service ${donneesResponse.toString()}');
      } else {
        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de l\'ajout de acteur : $e');
    }
  }

  // Future<List<Materiel>> fetchMateriel() async {
  //   final response = await http.get(Uri.parse('$baseUrl/list'));

  //   if (response.statusCode == 200) {
  //     List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
  //     materielList = body.map((item) => Materiel.fromMap(item)).toList();
  //     debugPrint(response.body);
  //     return materielList;
  //   } else {
  //     materielList = [];
  //     print('Échec de la requête avec le code d\'état: ${response.statusCode}');
  //     throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
  //   }
  // }

  // Future<List<Materiel>> fetchMaterielByActeur(String idActeur) async {
  //   final response =
  //       await http.get(Uri.parse('$baseUrl/readByActeur/$idActeur'));

  //   if (response.statusCode == 200) {
  //     List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
  //     materielList = body.map((item) => Materiel.fromMap(item)).toList();
  //     debugPrint(response.body);
  //     return materielList;
  //   } else {
  //     materielList = [];
  //     print('Échec de la requête avec le code d\'état: ${response.statusCode}');
  //     throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
  //   }
  // }

  Future<List<Materiels>> fetchMaterielByType(String id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/readByTypeMateriel/$id'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("Body : ${response.body.toString()}");
      materielList = body.map((item) => Materiels.fromMap(item)).toList();
      debugPrint(response.body);
      return materielList;
    } else {
      print(
          'Échec de la requête mat type avec le code d\'état: ${response.statusCode}');
      return materielList = [];
    }
  }

  Future<List<Materiels>> fetchMateriel(String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      materielList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getMaterielsByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();

          materielList.addAll(newMateriels.where((newMateriel) => !materielList.any((existeMate) => existeMate.idMateriel == newMateriel.idMateriel)));

          // materielList.addAll(newMateriels.where((newMat) => !newMateriels
          //     .any((existMat) => existMat.idMateriel == newMat.idMateriel)));
          // page++;
        }

        debugPrint(
            "response body all materiel by pays with pagination ${page} par défilement soit ${materielList.length}");
        return materielList;
      } else {
        print(
            'Échec de la requête mat pag avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiels: $e');
    } finally {
      isLoading = false;
    }
    return materielList;
  }

  Future<List<Materiels>> fetchMaterielByPays(String nomPays,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      materielList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getAllByPaysWithPagination?nomPays=$nomPays&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();

          materielList.addAll(newMateriels.where((newMateriel) => !materielList.any((existeMate) => existeMate.idMateriel == newMateriel.idMateriel)));

        }

        debugPrint(
            "response body all materiel by pays with pagination ${page} par défilement soit ${materielList.length}");
        return materielList;
      } else {
        print(
            'Échec de la requête mat pag avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiels: $e');
    } finally {
      isLoading = false;
    }
    return materielList;
  }
  Future<List<Materiels>> fetchMaterielByPaysAndFiliere(String libelleFiliere,String pays,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      materielList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getMaterielsByFiliereAndPaysWithPagination?libelleFiliere=$libelleFiliere&pays=$pays&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();

          materielList.addAll(newMateriels.where((newMateriel) => !materielList.any((existeMate) => existeMate.idMateriel == newMateriel.idMateriel)));

        }

        debugPrint(
            "response body all materiel by pays with pagination ${page} par défilement soit ${materielList.length}");
        return materielList;
      } else {
        print(
            'Échec de la requête mat pag avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiels: $e');
    } finally {
      isLoading = false;
    }
    return materielList;
  }

  Future<List<Materiels>> fetchMateriele(String pays, String libelleFiliere,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    // setState(() {
    // });
    isLoading = true;

    if (refresh) {
      // setState(() {
      // });
      materielList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getMaterielsByFiliereWithPagination?libelleFiliere=$libelleFiliere&pays=$pays&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          // setState(() {
          // });
          hasMore = false;
        } else {
          // setState(() {
          // });
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();

          materielList.addAll(newMateriels.where((newMateriel) =>
              !materielList.any((existeMate) =>
                  existeMate.idMateriel == newMateriel.idMateriel)));

        }

        debugPrint(
            "response body all materiel with pagination ${page} par défilement soit ${materielList.length}");
        return materielList;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiels: $e');
    } finally {
      // setState(() {
      // });
      isLoading = false;
    }
    return materielList;
  }

  Future<List<Materiels>> fetchMaterielByTypeAndPaysWithPagination(
      String idTypeMateriel,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      materielList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getAllMaterielsByTypeMaterielWithPagination?idTypeMateriel=${idTypeMateriel}&page=$page&size=$size'));

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();

          materielList.addAll(newMateriels.where((newMateriel) =>
              !materielList.any((existeMate) =>
                  existeMate.idMateriel == newMateriel.idMateriel)));

        }

        debugPrint(
            "response body all materiel by pays and type materiel with pagination ${page} par défilement soit ${materielList.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiel: $e');
    } finally {
      isLoading = false;
    }
    return materielList;
  }

  Future<List<Materiels>> fetchMaterielByTypeAndFiliere(
      String idTypeMateriel, String libelleFiliere, String pays,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      materielList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getMaterielsByIdTypeAndFiliere?idTypeMateriel=${idTypeMateriel}&libelleFiliere=$libelleFiliere&pays=$pays&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();

          materielList.addAll(newMateriels.where((newMateriel) =>
              !materielList.any((existeMate) =>
                  existeMate.idMateriel == newMateriel.idMateriel)));

        }

        debugPrint(
            "response body all materiel by pays and type materiel with pagination ${page} par défilement soit ${materielList.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiel: $e');
    } finally {
      isLoading = false;
    }
    return materielList;
  }

  Future<List<Materiels>> fetchMaterielByActeurWithPagination(String idActeur,
      {bool refresh = false}) async {
    if (isLoading) return [];

    isLoading = true;

    if (refresh) {
      materielList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Materiel/getAllMaterielsByActeurWithPagination?idActeur=$idActeur&page=$page&size=$size'));

      if (response.statusCode == 200) {
        // debugPrint("url: $response");
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Materiels> newMateriels =
              body.map((e) => Materiels.fromMap(e)).toList();

          materielList.addAll(newMateriels.where((newMateriel) =>
              !materielList.any((existeMate) =>
                  existeMate.idMateriel == newMateriel.idMateriel)));

        }

        debugPrint(
            "response body materiel by acteur with pagination $page par défilement soit ${materielList.length}");
        return materielList;
      } else {
        print(
            'Échec de la requête  mat avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des materiels: $e');
    } finally {
      isLoading = false;
    }
    return materielList;
  }

  Future<void> deleteMateriel(String idMateriel) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idMateriel"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerMateriel(String idMateriel) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$idMateriel"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverMateriel(String idMateriel) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idMateriel"));
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
