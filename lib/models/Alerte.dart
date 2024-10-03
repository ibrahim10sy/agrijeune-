import 'dart:convert';

import 'package:koumi/models/Acteur.dart';


class Alerte {
  final String? id;
  final String sujet;
  final String email;
  final String message;
  final String? dateAjout;
  final Acteur acteur;

  Alerte({
    this.id,
    required this.sujet,
    required this.email,
    required this.message,
    this.dateAjout,
    required this.acteur,
  });

  Alerte copyWith({
    String? id,
    String? sujet,
    String? email,
    String? message,
    String? dateAjout,
    Acteur? acteur,
  }) {
    return Alerte(
      id: id ?? this.id,
      sujet: sujet ?? this.sujet,
      email: email ?? this.email,
      message: message ?? this.message,
      dateAjout: dateAjout ?? this.dateAjout,
      acteur: acteur ?? this.acteur,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sujet': sujet,
      'email': email,
      'message': message,
      'dateAjout': dateAjout,
      'acteur': acteur.toMap(),
    };
  }

  factory Alerte.fromMap(Map<String, dynamic> map) {
    return Alerte(
      id: map['id'] != null ? map['id'] as String : null,
      sujet: map['sujet'] as String,
      email: map['email'] as String,
      message: map['message'] as String,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      acteur: Acteur.fromMap(map['acteur'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Alerte.fromJson(String source) => Alerte.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Alerte(id: $id, sujet: $sujet, email: $email, message: $message, dateAjout: $dateAjout, acteur: $acteur)';
  }

  @override
  bool operator ==(covariant Alerte other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.sujet == sujet &&
      other.email == email &&
      other.message == message &&
      other.dateAjout == dateAjout &&
      other.acteur == acteur;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      sujet.hashCode ^
      email.hashCode ^
      message.hashCode ^
      dateAjout.hashCode ^
      acteur.hashCode;
  }
}






  //  // Méthode pour créer une instance d'Acteur à partir des données de SharedPreferences
  // factory Acteur.fromSharedPreferencesData(String emailActeur, String password, 
  // List<String> userTypeList, String idActeur, String nomActeur, String telephoneActeur,
  //  String adressActeur, String whatsAppActeur, String niveau3PaysActeur,
  //   String localiteActeur) {
  //   // Créez une liste de TypeActeur à partir de la liste de chaînes userTypeList
  //   List<TypeActeur> typeActeurList = userTypeList.map((libelle) => TypeActeur(libelle: libelle)).toList();

  //   // Retournez une nouvelle instance d'Acteur avec les données fournies
  //   return Acteur(
  //     // Initialiser les autres propriétés de l'acteur selon vos besoins
  //     emailActeur: emailActeur,
  //     password: password,
  //     typeActeur: typeActeurList, 
  //     idActeur:idActeur,
  //     nomActeur: nomActeur, 
  //     adresseActeur: adressActeur,telephoneActeur: telephoneActeur,
  //     whatsAppActeur:whatsAppActeur, niveau3PaysActeur: niveau3PaysActeur, 
  //     localiteActeur:localiteActeur 
  //   );
  // }