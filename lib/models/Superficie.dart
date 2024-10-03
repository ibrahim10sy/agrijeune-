import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Campagne.dart';
import 'package:koumi/models/Speculation.dart';


class Superficie {
  String? idSuperficie;
  String? codeSuperficie;
  String? localite;
  String? personneModif;
  String? superficieHa;
  String? description;
  bool statutSuperficie;
  String? dateSemi;
  String? dateAjout;
  String? dateModif;
  Acteur acteur;
  List<String>? intrants;
  Speculation speculation;
  Campagne campagne;

  Superficie({
    this.idSuperficie,
    this.codeSuperficie,
    this.localite,
    this.personneModif,
    this.superficieHa,
    this.description,
    required this.statutSuperficie,
    this.dateSemi,
    this.dateAjout,
    this.dateModif,
    required this.acteur,
    this.intrants,
    required this.speculation,
    required this.campagne,
  });

  Superficie copyWith({
    String? idSuperficie,
    String? codeSuperficie,
    String? localite,
    String? personneModif,
    String? superficieHa,
    String? description,
    bool? statutSuperficie,
    String? dateSemi,
    String? dateAjout,
    String? dateModif,
    Acteur? acteur,
    List<String>? intrants,
    Speculation? speculation,
    Campagne? campagne,
  }) {
    return Superficie(
      idSuperficie: idSuperficie ?? this.idSuperficie,
      codeSuperficie: codeSuperficie ?? this.codeSuperficie,
      localite: localite ?? this.localite,
      personneModif: personneModif ?? this.personneModif,
      superficieHa: superficieHa ?? this.superficieHa,
      description: description ?? this.description,
      statutSuperficie: statutSuperficie ?? this.statutSuperficie,
      dateSemi: dateSemi ?? this.dateSemi,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      acteur: acteur ?? this.acteur,
      intrants: intrants ?? this.intrants,
      speculation: speculation ?? this.speculation,
      campagne: campagne ?? this.campagne,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idSuperficie': idSuperficie,
      'codeSuperficie': codeSuperficie,
      'localite': localite,
      'personneModif': personneModif,
      'superficieHa': superficieHa,
      'description': description,
      'statutSuperficie': statutSuperficie,
      'dateSemi': dateSemi,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'acteur': acteur.toMap(),
      'intrants': intrants,
      'speculation': speculation.toMap(),
      'campagne': campagne.toMap(),
    };
  }

 factory Superficie.fromMap(Map<String, dynamic> map) {
    return Superficie(
      idSuperficie: map['idSuperficie'] as String?,
      codeSuperficie: map['codeSuperficie'] as String?,
      localite: map['localite'] as String?,
      personneModif: map['personneModif'] as String?,
      superficieHa: map['superficieHa'] as String?,
      description: map['description'] as String?,
      statutSuperficie: map['statutSuperficie'] as bool,
      dateSemi: map['dateSemi'] as String?,
      dateAjout: map['dateAjout'] as String?,
      dateModif: map['dateModif'] as String?,
      acteur: Acteur.fromMap(map['acteur'] as Map<String, dynamic>),
      intrants:
          (map['intrants'] as List<dynamic>?)?.map((e) => e as String).toList(),
      speculation:  Speculation.fromMap(map['speculation'] as Map<String, dynamic>),
        
      campagne:  Campagne.fromMap(map['campagne'] as Map<String, dynamic>)
          
    );
  }


  String toJson() => json.encode(toMap());

  factory Superficie.fromJson(String source) => Superficie.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Superficie(idSuperficie: $idSuperficie, codeSuperficie: $codeSuperficie, localite: $localite, personneModif: $personneModif, superficieHa: $superficieHa, description: $description, statutSuperficie: $statutSuperficie, dateSemi: $dateSemi, dateAjout: $dateAjout, dateModif: $dateModif, acteur: $acteur, intrants: $intrants, speculation: $speculation, campagne: $campagne)';
  }

  @override
  bool operator ==(covariant Superficie other) {
    if (identical(this, other)) return true;
  
    return 
      other.idSuperficie == idSuperficie &&
      other.codeSuperficie == codeSuperficie &&
      other.localite == localite &&
      other.personneModif == personneModif &&
      other.superficieHa == superficieHa &&
      other.description == description &&
      other.statutSuperficie == statutSuperficie &&
      other.dateSemi == dateSemi &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.acteur == acteur &&
      listEquals(other.intrants, intrants) &&
      other.speculation == speculation &&
      other.campagne == campagne;
  }

  @override
  int get hashCode {
    return idSuperficie.hashCode ^
      codeSuperficie.hashCode ^
      localite.hashCode ^
      personneModif.hashCode ^
      superficieHa.hashCode ^
      description.hashCode ^
      statutSuperficie.hashCode ^
      dateSemi.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      acteur.hashCode ^
      intrants.hashCode ^
      speculation.hashCode ^
      campagne.hashCode;
  }
}
