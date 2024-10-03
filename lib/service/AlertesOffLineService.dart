import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/AlertesOffLine.dart';
import 'package:path/path.dart';

class AlertesOffLineService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/alertesOffLine';

  List<AlertesOffLine> alertesList = [];

  Future<void> creerAlertesOffLine({
  required String titreAlerteOffLine,
  required String descriptionAlerteOffLine,
  required String pays,
  required String codePays,
  File? audioAlerteOffLine,
  File? photoAlerteOffLine,
  File? videoAlerteOffLine,
}) async {
  try {
    var fullUrl = '$baseUrl/create';
    print('Request URL: $fullUrl'); // Log the URL

    var requete = http.MultipartRequest('POST', Uri.parse(fullUrl));

    if (audioAlerteOffLine != null) {
      requete.files.add(http.MultipartFile(
        'audioAlerteOffLine',
        audioAlerteOffLine.readAsBytes().asStream(),
        audioAlerteOffLine.lengthSync(),
        filename: basename(audioAlerteOffLine.path),
      ));
    }
    if (photoAlerteOffLine != null) {
      requete.files.add(http.MultipartFile(
        'imageAlerteOffLine',
        photoAlerteOffLine.readAsBytes().asStream(),
        photoAlerteOffLine.lengthSync(),
        filename: basename(photoAlerteOffLine.path),
      ));
    }
    if (videoAlerteOffLine != null) {
      requete.files.add(http.MultipartFile(
        'videoAlerteOffLine',
        videoAlerteOffLine.readAsBytes().asStream(),
        videoAlerteOffLine.lengthSync(),
        filename: basename(videoAlerteOffLine.path),
      ));
    }
    requete.fields['alerteOffLine'] = jsonEncode({
      'titreAlerteOffLine': titreAlerteOffLine,
      'descriptionAlerteOffLine': descriptionAlerteOffLine,
      'pays': pays,
      'codePays': codePays,
      'audioAlerteOffLine': '',
      'photoAlerteOffLine': '',
      'videoAlerteOffLine': '',
    });

    var response = await requete.send();
    var responsed = await http.Response.fromStream(response);

    if (response.statusCode == 200 || responsed.statusCode == 201 || responsed.statusCode == 202) {
      final donneesResponse = json.decode(responsed.body);
      debugPrint('alerte OffLine service ${donneesResponse.toString()}');
    } else {
      throw Exception('Échec de la requête avec le code d\'état : ${responsed.statusCode}');
    }
  } catch (e) {
    throw Exception('Une erreur s\'est produite lors de l\'ajout de Alertes OffLine : $e');
  }
}


   Future<void> updateAlertesOffLine(
      {required String idAlerteOffLine,
      required String titreAlerteOffLine,
      required String descriptionAlerteOffLine,
      required String pays,
      required String codePays,
      File? audioAlerteOffLine,
      File? photoAlerteOffLine,
      File? videoAlerteOffLine,
    }) async {
    try {
      var requete =
          http.MultipartRequest('PUT', Uri.parse('$baseUrl/update/$idAlerteOffLine'));

      if (audioAlerteOffLine != null) {
        requete.files.add(http.MultipartFile('audioAlerteOffLine',
            audioAlerteOffLine.readAsBytes().asStream(), audioAlerteOffLine.lengthSync(),
            filename: basename(audioAlerteOffLine.path)));
      }
      if (photoAlerteOffLine != null) {
        requete.files.add(http.MultipartFile('imageAlerteOffLine',
            photoAlerteOffLine.readAsBytes().asStream(), photoAlerteOffLine.lengthSync(),
            filename: basename(photoAlerteOffLine.path)));
      }
      if (videoAlerteOffLine != null) {
        requete.files.add(http.MultipartFile('videoAlerteOffLine',
            videoAlerteOffLine.readAsBytes().asStream(), videoAlerteOffLine.lengthSync(),
            filename: basename(videoAlerteOffLine.path)));
      }

      requete.fields['alerteOffLine'] = jsonEncode({
        'idAlerteOffLine':idAlerteOffLine,
        'titreAlerteOffLine': titreAlerteOffLine,
        'descriptionAlerteOffLine': descriptionAlerteOffLine,
        'pays': pays,
        'codePays': codePays,
        'audioAlerteOffLine': '',
        'photoAlerteOffLine': '',
        'videoAlerteOffLine': '',
      });

      var response = await requete.send();
      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 200 || responsed.statusCode == 201) {
        final donneesResponse = json.decode(responsed.body);
        debugPrint('alerte offline update service ${donneesResponse.toString()}');
      } else {
        throw Exception(
            'Échec de la requête avec le code d\'état : ${responsed.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Une erreur s\'est produite lors de la modification d\'alerte offlinne: $e');
    }
  }

   

  Future<List<AlertesOffLine>> fetchAlertes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/read'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Fetching data alerte offLine");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        print("Response body: $body"); // Imprimez le corps de la réponse pour vérifier son contenu

        List<AlertesOffLine> alertesList = body.map((e) => AlertesOffLine.fromMap(e)).toList();
        debugPrint(alertesList.toString());
        return alertesList;
      } else {
        print('Échec de la requête alerte offline avec le code d\'état: ${response.statusCode}');
        throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }



 
  Future<List<AlertesOffLine>> fetchAlertesOffLine() async {
  int page =0; 
  int size = 1000;
    try {
      final response = await http.get(Uri.parse('$baseUrl/getAllAlertesOffLineWithPagination?page=$page&size=$size'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Fetching data alertes offLine");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        alertesList = body.map((e) => AlertesOffLine.fromMap(e)).toList();
        debugPrint(alertesList.toString());
        return alertesList;
      } else {
        alertesList = [];
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode}');
        throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future deleteAlertesOffLine(String idAlertes) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete/$idAlertes'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future activerAlertesOffLine(String idAlertes) async {
    final response =  await http.put(Uri.parse('$baseUrl/enable/$idAlertes'));

    if (response.statusCode == 200 || response.statusCode == 201 ||
        response.statusCode == 202)    {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future desactiverAlertesOffLine(String idAlertes) async {
    final response =
 await http.put(Uri.parse('$baseUrl/disable/$idAlertes'));
    if (response.statusCode == 200 || response.statusCode == 201 ||
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
