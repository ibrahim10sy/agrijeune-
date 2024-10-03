import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeActeur.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ActeurProvider with ChangeNotifier {
  Acteur? _acteur;
  Acteur? _acteurUpdate;
  Acteur? get acteur => _acteur;
  Acteur? get acteurs => _acteurUpdate;
  bool isLogged = false;

  // Méthode pour initialiser les données de l'utilisateur à partir de SharedPreferences
  Future<void> initializeActeurFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idActeur = prefs.getString('idActeur');
    String? emailActeur = prefs.getString('emailActeur');
    String? codeActeur = prefs.getString('codeActeur');
    String? password = prefs.getString('password');
    List<String>? userTypeList = prefs.getStringList('userType');
    List<String>? speculationList = prefs.getStringList('specType');
    String? nomActeur = prefs.getString('nomActeur');
    String? adresseActeur = prefs.getString('adresseActeur');
    String? telephoneActeur = prefs.getString('telephoneActeur');
    String? whatsAppActeur = prefs.getString('whatsAppActeur');
    String? niveau3PaysActeur = prefs.getString('niveau3PaysActeur');
    String? localiteActeur = prefs.getString('localiteActeur');

    if (whatsAppActeur != null) {
      // L'utilisateur est connecté
      isLogged = true;
    } else {
      // L'utilisateur n'est pas connecté
      isLogged = false;
    }

    if (emailActeur != null &&
        password != null &&
        userTypeList != null &&
        speculationList != null &&
        codeActeur != null &&
        idActeur != null &&
        nomActeur != null &&
        adresseActeur != null &&
        telephoneActeur != null &&
        whatsAppActeur != null &&
        niveau3PaysActeur != null &&
        localiteActeur != null) {
      _acteur = Acteur.fromSharedPreferencesData(
          emailActeur,
          password,
          userTypeList,
          speculationList,
          codeActeur,
          idActeur,
          nomActeur,
          telephoneActeur,
          adresseActeur,
          whatsAppActeur,
          niveau3PaysActeur,
          localiteActeur);
      notifyListeners();
    }
  }

  void setActeur(Acteur newActeur) {
    _acteur = newActeur;
    List<TypeActeur> typeActeurList = newActeur.typeActeur!;
    print("Provider Type acteur ${typeActeurList.toString()}");
    print("new acteur ${newActeur}");
    notifyListeners();
  }

  void setActeurUpdate(Acteur newActeurs) {
    _acteurUpdate = newActeurs;

    print("new acteur ${newActeurs.toString()}");
    notifyListeners();
  }

  Future<void> logout() async {
    // Récupérer les données utilisateur avant de les effacer
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? whatsAppActeur = prefs.getString('whatsAppActeur');
    String? codeActeur = prefs.getString('codeActeur');

    // Effacer toutes les préférences
    // Réinitialiser l'acteur local
    _acteur = null;

    await prefs.clear();
    if (whatsAppActeur == null || whatsAppActeur.isEmpty) {
      debugPrint("whatsAppActeur shared : $whatsAppActeur");
    } else {
      debugPrint("whatsAppActeur shared isExist : $whatsAppActeur");
    }

    if (codeActeur != null) {
      prefs.setString('codeActeur', codeActeur);
      print("code acteur apres logout : $codeActeur");
    }

    // Mettre à jour l'état de la connexion
    isLogged = false;
    notifyListeners();
  }
}
