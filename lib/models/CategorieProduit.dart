import 'dart:convert';

import 'package:koumi/models/Filiere.dart';


class CategorieProduit {
  final String? idCategorieProduit;
  String? codeCategorie;
  final String? libelleCategorie;
  final String? descriptionCategorie;
  final bool? statutCategorie;
  final String? dateAjout;
  final String? personneModif;
  final String? dateModif;
  final Filiere? filiere;
  
  CategorieProduit({
    this.idCategorieProduit,
    this.codeCategorie,
    this.libelleCategorie,
    this.descriptionCategorie,
    this.statutCategorie,
    this.dateAjout,
    this.personneModif,
    this.dateModif,
    this.filiere,
  });
  
 

  CategorieProduit copyWith({
    String? idCategorieProduit,
    String? codeCategorie,
    String? libelleCategorie,
    String? descriptionCategorie,
    bool? statutCategorie,
    String? dateAjout,
    String? personneModif,
    String? dateModif,
    Filiere? filiere,
  }) {
    return CategorieProduit(
      idCategorieProduit: idCategorieProduit ?? this.idCategorieProduit,
      codeCategorie: codeCategorie ?? this.codeCategorie,
      libelleCategorie: libelleCategorie ?? this.libelleCategorie,
      descriptionCategorie: descriptionCategorie ?? this.descriptionCategorie,
      statutCategorie: statutCategorie ?? this.statutCategorie,
      dateAjout: dateAjout ?? this.dateAjout,
      personneModif: personneModif ?? this.personneModif,
      dateModif: dateModif ?? this.dateModif,
      filiere: filiere ?? this.filiere,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idCategorieProduit': idCategorieProduit,
      'codeCategorie': codeCategorie,
      'libelleCategorie': libelleCategorie,
      'descriptionCategorie': descriptionCategorie,
      'statutCategorie': statutCategorie,
      'dateAjout': dateAjout,
      'personneModif': personneModif,
      'dateModif': dateModif,
      'filiere': filiere?.toMap(),
    };
  }

  factory CategorieProduit.fromMap(Map<String, dynamic> map) {
    return CategorieProduit(
      idCategorieProduit: map['idCategorieProduit'] != null ? map['idCategorieProduit'] as String : null,
      codeCategorie: map['codeCategorie'] != null ? map['codeCategorie'] as String : null,
      libelleCategorie: map['libelleCategorie'] != null ? map['libelleCategorie'] as String : null,
      descriptionCategorie: map['descriptionCategorie'] != null ? map['descriptionCategorie'] as String : null,
      statutCategorie: map['statutCategorie'] != null ? map['statutCategorie'] as bool : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      filiere: map['filiere'] != null ? Filiere.fromMap(map['filiere'] as Map<String,dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategorieProduit.fromJson(String source) => CategorieProduit.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CategorieProduit(idCategorieProduit: $idCategorieProduit, codeCategorie: $codeCategorie, libelleCategorie: $libelleCategorie, descriptionCategorie: $descriptionCategorie, statutCategorie: $statutCategorie, dateAjout: $dateAjout, personneModif: $personneModif, dateModif: $dateModif, filiere: $filiere)';
  }

  @override
  bool operator ==(covariant CategorieProduit other) {
    if (identical(this, other)) return true;
  
    return 
      other.idCategorieProduit == idCategorieProduit &&
      other.codeCategorie == codeCategorie &&
      other.libelleCategorie == libelleCategorie &&
      other.descriptionCategorie == descriptionCategorie &&
      other.statutCategorie == statutCategorie &&
      other.dateAjout == dateAjout &&
      other.personneModif == personneModif &&
      other.dateModif == dateModif &&
      other.filiere == filiere;
  }

  @override
  int get hashCode {
    return idCategorieProduit.hashCode ^
      codeCategorie.hashCode ^
      libelleCategorie.hashCode ^
      descriptionCategorie.hashCode ^
      statutCategorie.hashCode ^
      dateAjout.hashCode ^
      personneModif.hashCode ^
      dateModif.hashCode ^
      filiere.hashCode;
  }
}
