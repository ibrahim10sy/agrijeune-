import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/ParametreGeneraux.dart';
import 'package:path/path.dart';

class ParametreGenerauxService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/parametreGeneraux';


  List<ParametreGeneraux> parametreList = [];
  List<ParametreGeneraux> _parametreList = [];
  ParametreGeneraux? _parametre;

  List<ParametreGeneraux> get parametreListe => _parametreList;
  ParametreGeneraux? get param => _parametre;

  void setParametreList(List<ParametreGeneraux> list) {
    _parametreList = list;
    notifyListeners();
  }

  void setParametre(ParametreGeneraux newParametre) {
    _parametre = newParametre;
    notifyListeners();
  }

  Future<void> addParametre({
    required String sigleStructure,
    required String nomStructure,
    required String sigleSysteme,
    required String nomSysteme,
    required String descriptionSysteme,
    required String sloganSysteme,
    File? logoSysteme,
    required String adresseStructure,
    required String emailStructure,
    required String telephoneStructure,
    required String whattsAppStructure,
    required String libelleNiveau1Pays,
    required String libelleNiveau2Pays,
    required String libelleNiveau3Pays,
    required String localiteStructure,
  }) async {
    try {
      var requete = http.MultipartRequest('POST', Uri.parse('$baseUrl/create'));

      if (logoSysteme != null) {
        requete.files.add(http.MultipartFile('image',
            logoSysteme.readAsBytes().asStream(), logoSysteme.lengthSync(),
            filename: basename(logoSysteme.path)));
      }

      requete.fields['param'] = jsonEncode({
        'idParametreGeneraux': null,
        'sigleStructure': sigleStructure,
        'nomStructure': nomStructure,
        'sigleSysteme': sigleSysteme,
        'nomSysteme': nomSysteme,
        'descriptionSysteme': descriptionSysteme,
        'sloganSysteme': sloganSysteme,
        'logoSysteme': "",
        'adresseStructure': adresseStructure,
        'emailStructure': emailStructure,
        'telephoneStructure': telephoneStructure,
        'whattsAppStructure': whattsAppStructure,
        'libelleNiveau1Pays': libelleNiveau1Pays,
        'libelleNiveau2Pays': libelleNiveau2Pays,
        'libelleNiveau3Pays': libelleNiveau3Pays,
        'localiteStructure': localiteStructure,
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('parametreGeneraux service ${donneesResponse.toString()}');
      } else {
        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de l\'ajout de acteur : $e');
    }
  }

  Future<void> updateParametre({
    required String idParametreGeneraux,
    required String sigleStructure,
    required String nomStructure,
    required String sigleSysteme,
    required String nomSysteme,
    required String descriptionSysteme,
    required String sloganSysteme,
    // required String monnaie,
    // required String tauxDollar,
    // required String tauxYuan,
    File? logoSysteme,
    required String adresseStructure,
    required String emailStructure,
    required String telephoneStructure,
    required String whattsAppStructure,
    // required String libelleNiveau1Pays,
    // required String libelleNiveau2Pays,
    // required String libelleNiveau3Pays,
    required String localiteStructure,
  }) async {
    try {
      var requete = http.MultipartRequest(
          'PUT',
          Uri.parse(
              '$apiOnlineUrl/parametreGeneraux/update/$idParametreGeneraux'));

      if (logoSysteme != null) {
        requete.files.add(http.MultipartFile('image',
            logoSysteme.readAsBytes().asStream(), logoSysteme.lengthSync(),
            filename: basename(logoSysteme.path)));
      }

      requete.fields['parametreGeneral'] = jsonEncode({
        'idParametreGeneraux': idParametreGeneraux,
        'sigleStructure': sigleStructure,
        'nomStructure': nomStructure,
        'sigleSysteme': sigleSysteme,
        'nomSysteme': nomSysteme,
        'descriptionSysteme': descriptionSysteme,
        'sloganSysteme': sloganSysteme,
        'logoSysteme': "",
        'adresseStructure': adresseStructure,
        'emailStructure': emailStructure,
       
        'telephoneStructure': telephoneStructure,
        'whattsAppStructure': whattsAppStructure,
       
        'localiteStructure': localiteStructure,
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('parametreGeneraux service ${donneesResponse.toString()}');
      } else {
        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de la modification : $e');
    }
  }

  Future<List<ParametreGeneraux>> fetchParametre() async {
    final response = await http.get(Uri.parse('$baseUrl/read'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      parametreList =
          body.map((item) => ParametreGeneraux.fromMap(item)).toList();
      // debugPrint(response.body);
      return parametreList;
    } else {
      parametreList = [];
      print('Échec de la requête para avec le code d\'état: ${response.statusCode}');
       
      // throw Exception("Params vide");
      // throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
          return parametreList;

  }

  Future<List<ParametreGeneraux>> fetchParametreById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/readById/$id'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      parametreList =
          body.map((item) => ParametreGeneraux.fromMap(item)).toList();
      // debugPrint(response.body);
      return parametreList;
    } else {
      parametreList = [];
      print('Échec de la requête para id avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future<void> deleteParametre(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/delete/$id"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  void applyChange() {
    notifyListeners();
  }
}
