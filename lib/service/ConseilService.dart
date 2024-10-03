import 'dart:convert';
import 'dart:io'; 

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Conseil.dart';
import 'package:path/path.dart';

class ConseilService extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/conseil';

  List<Conseil> conseilList = [];

   Future<void> creerConseil({
      required String titreConseil,
      required String descriptionConseil,
      File? audioConseil,
      File? photoConseil,
      File? videoConseil,
      required Acteur acteur}) async {
    try {
      var requete = http.MultipartRequest('POST', Uri.parse('$baseUrl/create'));

      if (audioConseil != null) {
        requete.files.add(http.MultipartFile('audio',
            audioConseil.readAsBytes().asStream(), audioConseil.lengthSync(),
            filename: basename(audioConseil.path)));
      }
      if (photoConseil != null) {
        requete.files.add(http.MultipartFile('image',
            photoConseil.readAsBytes().asStream(), photoConseil.lengthSync(),
            filename: basename(photoConseil.path)));
      }
      if (videoConseil != null) {
        requete.files.add(http.MultipartFile('video',
            videoConseil.readAsBytes().asStream(), videoConseil.lengthSync(),
            filename: basename(videoConseil.path)));
      }

      requete.fields['conseil'] = jsonEncode({
        'titreConseil': titreConseil,
        'descriptionConseil': descriptionConseil,
        'audioConseil' : '',
        'photoConseil' : '',
        'videoConseil' : '',
        'acteur' : acteur.toMap(),
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
          'Une erreur s\'est produite lors de l\'ajout de conseil : $e');
    }
  }

   Future<void> updateConseil({
      required String idConseil,
      required String titreConseil,
      required String descriptionConseil,
      File? audioConseil,
      File? photoConseil,
      File? videoConseil,
      required Acteur acteur}) async {
    try {
      var requete = http.MultipartRequest('PUT', Uri.parse('$baseUrl/update/$idConseil'));

      if (audioConseil != null) {
        requete.files.add(http.MultipartFile('audio',
            audioConseil.readAsBytes().asStream(), audioConseil.lengthSync(),
            filename: basename(audioConseil.path)));
      }
      if (photoConseil != null) {
        requete.files.add(http.MultipartFile('image',
            photoConseil.readAsBytes().asStream(), photoConseil.lengthSync(),
            filename: basename(photoConseil.path)));
      }
      if (videoConseil != null) {
        requete.files.add(http.MultipartFile('video',
            videoConseil.readAsBytes().asStream(), videoConseil.lengthSync(),
            filename: basename(videoConseil.path)));
      }

      requete.fields['conseil'] = jsonEncode({
        'idConseil' : idConseil,
        'titreConseil': titreConseil,
        'descriptionConseil': descriptionConseil,
        'audioConseil': '',
        'photoConseil': '',
        'videoConseil': '',
        'acteur': acteur.toMap(),
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
          'Une erreur s\'est produite lors de la modification : $e');
    }
  }


  Future<List<Conseil>> fetchConseil() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/read'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Fetching data");
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        conseilList = body.map((e) => Conseil.fromMap(e)).toList();
        debugPrint(conseilList.toString());
        return conseilList;
      } else {
        conseilList = [];
        print(
            'Échec de la requête conseil  avec le code d\'état: ${response.statusCode}');
        throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future deleteConseil(String idConseil) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete/$idConseil'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future activerConseil(String idConseil) async {
    final response = await http.put(Uri.parse('$baseUrl/enable/$idConseil'));

    if (response.statusCode == 200 || response.statusCode == 201 ||
        response.statusCode == 202) {
      applyChange();
    } else {
      print('Échec de la requête avec le code d\'état: ${response.statusCode}');
      throw Exception(jsonDecode(utf8.decode(response.bodyBytes))["message"]);
    }
  }

  Future desactiverConseil(String idConseil) async {
    final response = await http.put(Uri.parse('$baseUrl/disable/$idConseil'));

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
