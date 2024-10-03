import 'dart:convert';

import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Forme.dart';
import 'package:koumi/models/Monnaie.dart';


class Intrant {
  final String? idIntrant;
  String? nomIntrant;
  double? quantiteIntrant;
  int? nbreView;
  int? prixIntrant;
  final String? codeIntrant;
  final String? descriptionIntrant;
  final String? photoIntrant;
  final bool? statutIntrant;
  final String? dateExpiration;
  final String? dateAjout;
  final String? dateModif;
  final String? personneModif;
  final String? unite;
  final String? pays;
  final Forme? forme;
  final Acteur? acteur;
  final CategorieProduit? categorieProduit;
  final Monnaie? monnaie;
  
  Intrant({
    this.idIntrant,
    this.nomIntrant,
    this.quantiteIntrant,
    this.prixIntrant,
    this.nbreView,
    this.codeIntrant,
    this.descriptionIntrant,
    this.photoIntrant,
    this.statutIntrant,
    this.dateExpiration,
    this.dateAjout,
    this.dateModif,
    this.personneModif,
    this.unite,
    this.pays,
    this.forme,
    this.acteur,
    this.categorieProduit,
    this.monnaie,
  });
  
 

  Intrant copyWith({
    String? idIntrant,
    String? nomIntrant,
    double? quantiteIntrant,
    int? prixIntrant,
    int? nbreView,
    String? codeIntrant,
    String? descriptionIntrant,
    String? photoIntrant,
    bool? statutIntrant,
    String? dateExpiration,
    String? dateAjout,
    String? dateModif,
    String? personneModif,
    String? unite,
    String? pays,
    Forme? forme,
    Acteur? acteur,
    CategorieProduit? categorieProduit,
    Monnaie? monnaie,
  }) {
    return Intrant(
      idIntrant: idIntrant ?? this.idIntrant,
      nomIntrant: nomIntrant ?? this.nomIntrant,
      quantiteIntrant: quantiteIntrant ?? this.quantiteIntrant,
      prixIntrant: prixIntrant ?? this.prixIntrant,
      nbreView: nbreView ?? this.nbreView,
      codeIntrant: codeIntrant ?? this.codeIntrant,
      descriptionIntrant: descriptionIntrant ?? this.descriptionIntrant,
      photoIntrant: photoIntrant ?? this.photoIntrant,
      statutIntrant: statutIntrant ?? this.statutIntrant,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      personneModif: personneModif ?? this.personneModif,
      unite: unite ?? this.unite,
      pays: pays ?? this.pays,
      forme: forme ?? this.forme,
      acteur: acteur ?? this.acteur,
      categorieProduit: categorieProduit ?? this.categorieProduit,
      monnaie: monnaie ?? this.monnaie,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idIntrant': idIntrant,
      'nomIntrant': nomIntrant,
      'quantiteIntrant': quantiteIntrant,
      'prixIntrant': prixIntrant,
      'nbreView': nbreView,
      'codeIntrant': codeIntrant,
      'descriptionIntrant': descriptionIntrant,
      'photoIntrant': photoIntrant,
      'statutIntrant': statutIntrant,
      'dateExpiration': dateExpiration,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'personneModif': personneModif,
      'unite': unite,
      'pays': pays,
      'forme': forme?.toMap(),
      'acteur': acteur?.toMap(),
      'categorieProduit': categorieProduit?.toMap(),
      'monnaie': monnaie?.toMap(),
    };
  }

  factory Intrant.fromMap(Map<String, dynamic> map) {
    return Intrant(
      idIntrant: map['idIntrant'] != null ? map['idIntrant'] as String : null,
      nomIntrant: map['nomIntrant'] != null ? map['nomIntrant'] as String : null,
      quantiteIntrant: map['quantiteIntrant'] != null ? map['quantiteIntrant'] as double : null,
      prixIntrant: map['prixIntrant'] != null ? map['prixIntrant'] as int : null,
      nbreView: map['nbreView'] != null ? map['nbreView'] as int : null,
      codeIntrant: map['codeIntrant'] != null ? map['codeIntrant'] as String : null,
      descriptionIntrant: map['descriptionIntrant'] != null ? map['descriptionIntrant'] as String : null,
      photoIntrant: map['photoIntrant'] != null ? map['photoIntrant'] as String : null,
      statutIntrant: map['statutIntrant'] != null ? map['statutIntrant'] as bool : null,
      dateExpiration: map['dateExpiration'] != null ? map['dateExpiration'] as String : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      unite: map['unite'] != null ? map['unite'] as String : null,
      pays: map['pays'] != null ? map['pays'] as String : null,
      forme: map['forme'] != null ? Forme.fromMap(map['forme'] as Map<String,dynamic>) : null,
      acteur: map['acteur'] != null ? Acteur.fromMap(map['acteur'] as Map<String,dynamic>) : null,
      categorieProduit: map['categorieProduit'] != null ? CategorieProduit.fromMap(map['categorieProduit'] as Map<String,dynamic>) : null,
      monnaie: map['monnaie'] != null ? Monnaie.fromMap(map['monnaie'] as Map<String,dynamic>) : null,
    );
  }



  String toJson() => json.encode(toMap());

  factory Intrant.fromJson(String source) => Intrant.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Intrant(idIntrant: $idIntrant, nomIntrant: $nomIntrant, quantiteIntrant: $quantiteIntrant, prixIntrant: $prixIntrant, codeIntrant: $codeIntrant, descriptionIntrant: $descriptionIntrant, photoIntrant: $photoIntrant, statutIntrant: $statutIntrant, dateExpiration: $dateExpiration, dateAjout: $dateAjout, dateModif: $dateModif, personneModif: $personneModif, unite: $unite, pays: $pays, forme: $forme, acteur: $acteur, categorieProduit: $categorieProduit, monnaie: $monnaie)';
  }

  @override
  bool operator ==(covariant Intrant other) {
    if (identical(this, other)) return true;
  
    return 
      other.idIntrant == idIntrant &&
      other.nomIntrant == nomIntrant &&
      other.quantiteIntrant == quantiteIntrant &&
      other.prixIntrant == prixIntrant &&
      other.nbreView == nbreView &&
      other.codeIntrant == codeIntrant &&
      other.descriptionIntrant == descriptionIntrant &&
      other.photoIntrant == photoIntrant &&
      other.statutIntrant == statutIntrant &&
      other.dateExpiration == dateExpiration &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.personneModif == personneModif &&
      other.unite == unite &&
      other.pays == pays &&
      other.forme == forme &&
      other.acteur == acteur &&
      other.categorieProduit == categorieProduit &&
      other.monnaie == monnaie;
  }

  @override
  int get hashCode {
    return idIntrant.hashCode ^
      nomIntrant.hashCode ^
      quantiteIntrant.hashCode ^
      prixIntrant.hashCode ^
      nbreView.hashCode ^
      codeIntrant.hashCode ^
      descriptionIntrant.hashCode ^
      photoIntrant.hashCode ^
      statutIntrant.hashCode ^
      dateExpiration.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      personneModif.hashCode ^
      unite.hashCode ^
      pays.hashCode ^
      forme.hashCode ^
      acteur.hashCode ^
      categorieProduit.hashCode ^
      monnaie.hashCode;
  }
}
