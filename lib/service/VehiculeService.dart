import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/models/Vehicule.dart';
import 'package:path/path.dart';

class VehiculeService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/vehicule';

  List<Vehicule> vehiculeList = [];
  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;

  Future<void> addVehicule(
      {required String nomVehicule,
      required String capaciteVehicule,
      required Map<String, int> prixParDestination,
      required String etatVehicule,
      required String localisation,
      required String description,
      required String nbKilometrage,
      File? photoVehicule,
      required TypeVoiture typeVoiture,
      required Acteur acteur,
      required Monnaie monnaie}) async {
    try {
      var requete = http.MultipartRequest('POST', Uri.parse('$baseUrl/create'));

      if (photoVehicule != null) {
        requete.files.add(http.MultipartFile('image',
            photoVehicule.readAsBytes().asStream(), photoVehicule.lengthSync(),
            filename: basename(photoVehicule.path)));
      }

      requete.fields['vehicule'] = jsonEncode({
        'prixParDestination': prixParDestination,
        'nomVehicule': nomVehicule,
        'etatVehicule': etatVehicule,
        'localisation': localisation,
        'description': description,
        'photoVehicule': '',
        'nbKilometrage': int.tryParse(nbKilometrage),
        'capaciteVehicule': capaciteVehicule,
        'typeVoiture': typeVoiture.toMap(),
        'acteur': acteur.toMap(),
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
      throw Exception('Une erreur s\'est produite lors de l\'ajout  : $e');
    }
  }

  Future<void> updateVehicule(
      {required String idVehicule,
      required String nomVehicule,
      required String capaciteVehicule,
      required Map<String, int> prixParDestination,
      required String etatVehicule,
      required String localisation,
      required String description,
      required String nbKilometrage,
      File? photoVehicule,
      required TypeVoiture typeVoiture,
      required Acteur acteur,
      required Monnaie monnaie}) async {
    try {
      var requete = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl/update/$idVehicule'));

      if (photoVehicule != null) {
        requete.files.add(http.MultipartFile('image',
            photoVehicule.readAsBytes().asStream(), photoVehicule.lengthSync(),
            filename: basename(photoVehicule.path)));
      }

      requete.fields['vehicule'] = jsonEncode({
        'idVehicule': idVehicule,
        'prixParDestination': prixParDestination,
        'nomVehicule': nomVehicule,
        'etatVehicule': etatVehicule,
        'localisation': localisation,
        'description': description,
        'photoVehicule': '',
        'nbKilometrage': int.tryParse(nbKilometrage),
        'capaciteVehicule': capaciteVehicule,
        'typeVoiture': typeVoiture.toMap(),
        'acteur': acteur.toMap(),
        'monnaie': monnaie.toMap(),
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('vehicule modifier ${donneesResponse.toString()}');
      } else {
        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de la modification : $e');
    }
  }

  Future<List<Vehicule>> fetchVehiculeByTypeVehicule(String id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/listeVehiculeByType/$id'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("Body : ${response.body.toString()}");
      vehiculeList = body.map((item) => Vehicule.fromMap(item)).toList();
      debugPrint(response.body);
      return vehiculeList;
    } else {
      vehiculeList = [];
      print(
          'Échec de la requête  v type avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<List<Vehicule>> fetchVehiculeByTypeVoitureWithPagination(
      String idTypeVoiture, String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading) return [];
    isLoading = true;

    if (refresh) {
      vehiculeList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/vehicule/getVehiculesByPaysAndTypeVoitureWithPagination?idTypeVoiture=$idTypeVoiture&niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint("url: $response");
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Vehicule> newVehicule =
              body.map((e) => Vehicule.fromMap(e)).toList();
          vehiculeList.addAll(newVehicule.where((newVe) => !vehiculeList
              .any((existeVe) => existeVe.idVehicule == newVe.idVehicule)));
        }

        debugPrint(
            "response body vehicle by type vehicule and pays with pagination $page par défilement soit ${vehiculeList.length}");
        return vehiculeList;
      } else {
        print(
            'Échec de la requête v type pag avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des vehicules: $e');
    } finally {
      isLoading = false;
    }
    return vehiculeList;
  }

  Future<List<Vehicule>> fetchVehicule(String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading) return [];

    isLoading = true;

    if (refresh) {
      vehiculeList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/vehicule/getVehiculesByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/vehicule/getVehiculesByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Vehicule> newVehicule =
              body.map((e) => Vehicule.fromMap(e)).toList();
          vehiculeList.addAll(newVehicule.where((newVe) => !vehiculeList
              .any((existeVe) => existeVe.idVehicule == newVe.idVehicule)));
        }

        debugPrint(
            "response body all vehicle by pays with pagination dans le service $page par défilement soit ${vehiculeList.length}");
        return vehiculeList;
      } else {
        print(
            'Échec de la requête v type pag avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des vehicules: $e');
    } finally {
      isLoading = false;
    }
    return vehiculeList;
  }

  Future<List<Vehicule>> fetchVehiculeByPays(String nomPays,
      {bool refresh = false}) async {
    if (isLoading) return [];

    isLoading = true;

    if (refresh) {
      vehiculeList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/vehicule/getAllByPaysWithPagination?nomPays=$nomPays&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/vehicule/getAllByPaysWithPagination?nomPays=$nomPays&page=$page&size=$size');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Vehicule> newVehicule =
              body.map((e) => Vehicule.fromMap(e)).toList();
          vehiculeList.addAll(newVehicule.where((newVe) => !vehiculeList
              .any((existeVe) => existeVe.idVehicule == newVe.idVehicule)));
        }

        debugPrint(
            "response body all vehicle by pays with pagination dans le service $page par défilement soit ${vehiculeList.length}");
        return vehiculeList;
      } else {
        print(
            'Échec de la requête v type pag avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des vehicules: $e');
    } finally {
      isLoading = false;
    }
    return vehiculeList;
  }

  Future<List<Vehicule>> fetchVehiculeByActeur(String idActeur,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

    isLoading = true;

    if (refresh) {
      vehiculeList.clear();
      page = 0;
      hasMore = true;
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/vehicule/getAllVehiculesByActeurWithPagination?idActeur=$idActeur&page=${page}&size=${size}'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          hasMore = false;
        } else {
          List<Vehicule> newVehicule =
              body.map((e) => Vehicule.fromMap(e)).toList();
          vehiculeList.addAll(newVehicule.where((newVe) => !vehiculeList
              .any((existeVe) => existeVe.idVehicule == newVe.idVehicule)));
        }

        debugPrint(
            "response body all vehicule by acteur with pagination ${page} par défilement soit ${vehiculeList.length}");
      } else {
        print(
            'Échec de la requête v ac avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des vehicule: $e');
    } finally {
      isLoading = false;
    }
    return vehiculeList;
  }

  Future<void> deleteVehicule(String idVehicule) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/delete/$idVehicule"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future activerVehicules(String id) async {
    final response = await http.put(Uri.parse('$baseUrl/enable/$id'));

    if (response.statusCode == 200 || response.statusCode == 202) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future desactiverVehicules(String id) async {
    final response = await http.put(Uri.parse('$baseUrl/disable/$id'));

    if (response.statusCode == 200 || response.statusCode == 202) {
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
