// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:koumi/models/Acteur.dart';


class Campagne {
  final String? idCampagne;
  final String codeCampagne;
  final String nomCampagne;
  final String description;
  final String? personneModif;
  final bool statutCampagne;
  final String? dateAjout;
  final String? dateModif;
  final Acteur acteur;
  Campagne({
    this.idCampagne,
    required this.codeCampagne,
    required this.nomCampagne,
    required this.description,
    this.personneModif,
    required this.statutCampagne,
    this.dateAjout,
    this.dateModif,
    required this.acteur,
  });

  Campagne copyWith({
    String? idCampagne,
    String? codeCampagne,
    String? nomCampagne,
    String? description,
    String? personneModif,
    bool? statutCampagne,
    String? dateAjout,
    String? dateModif,
    Acteur? acteur,
  }) {
    return Campagne(
      idCampagne: idCampagne ?? this.idCampagne,
      codeCampagne: codeCampagne ?? this.codeCampagne,
      nomCampagne: nomCampagne ?? this.nomCampagne,
      description: description ?? this.description,
      personneModif: personneModif ?? this.personneModif,
      statutCampagne: statutCampagne ?? this.statutCampagne,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      acteur: acteur ?? this.acteur,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idCampagne': idCampagne,
      'codeCampagne': codeCampagne,
      'nomCampagne': nomCampagne,
      'description': description,
      'personneModif': personneModif,
      'statutCampagne': statutCampagne,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'acteur': acteur.toMap(),
    };
  }

  factory Campagne.fromMap(Map<String, dynamic> map) {
    return Campagne(
      idCampagne: map['idCampagne'] != null ? map['idCampagne'] as String : null,
      codeCampagne: map['codeCampagne'] as String,
      nomCampagne: map['nomCampagne'] as String,
      description: map['description'] as String,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      statutCampagne: map['statutCampagne'] as bool,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      acteur: Acteur.fromMap(map['acteur'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Campagne.fromJson(String source) => Campagne.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Campagne(idCampagne: $idCampagne, codeCampagne: $codeCampagne, nomCampagne: $nomCampagne, description: $description, personneModif: $personneModif, statutCampagne: $statutCampagne, dateAjout: $dateAjout, dateModif: $dateModif, acteur: $acteur)';
  }

  @override
  bool operator ==(covariant Campagne other) {
    if (identical(this, other)) return true;
  
    return 
      other.idCampagne == idCampagne &&
      other.codeCampagne == codeCampagne &&
      other.nomCampagne == nomCampagne &&
      other.description == description &&
      other.personneModif == personneModif &&
      other.statutCampagne == statutCampagne &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.acteur == acteur;
  }

  @override
  int get hashCode {
    return idCampagne.hashCode ^
      codeCampagne.hashCode ^
      nomCampagne.hashCode ^
      description.hashCode ^
      personneModif.hashCode ^
      statutCampagne.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      acteur.hashCode;
  }
}
