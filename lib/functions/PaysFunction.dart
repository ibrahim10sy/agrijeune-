import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';

class PaysFunction extends ChangeNotifier{


      bool isLoadingLibelle = true;
    String? libelleNiveau1Pays;
    String? libelleNiveau2Pays;
    String? libelleNiveau3Pays;
    Acteur? _acteur;

 void setActeur(Acteur acteur) {
    _acteur = acteur;
    notifyListeners();
  }
 
    
  Future<String> getLibelleNiveau1PaysByActor(String id) async {
    final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau1Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response.body;  // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau1Pays');
    }
}
  Future<String> getLibelleNiveau2PaysByActor(String id) async {
    final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau2Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response.body;  // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau2Pays');
    }
}
  Future<String> getLibelleNiveau3PaysByActor(String id) async {
    final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau3Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response.body;  // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau3Pays');
    }
}

  //    Future<void> fetchLibelleNiveau3Pays() async {
  //   try {
  //     String libelle1 = await getLibelleNiveau1PaysByActor(acteur.idActeur!);
  //     String libelle2 = await getLibelleNiveau2PaysByActor(acteur.idActeur!);
  //     String libelle3 = await getLibelleNiveau3PaysByActor(acteur.idActeur!);
  //       libelleNiveau1Pays = libelle1;
  //       libelleNiveau2Pays = libelle2;
  //       libelleNiveau3Pays = libelle3;
  //       isLoadingLibelle = false;
  //   } catch (e) {
  //       isLoadingLibelle = false;
  //     print('Error: $e');
  //   }
  // }

   
 }