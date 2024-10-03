import 'dart:convert';

import 'package:koumi/models/SousRegion.dart';


class Pays {
 String? idPays;
    String? codePays;
    String? nomPays;
    String? libelleNiveau1Pays;
    String? libelleNiveau2Pays;
    String? libelleNiveau3Pays;
    String? monnaie;
    String? descriptionPays;
    String? whattsAppPays;
    String? personneModif;
    bool? statutPays;
    String? dateAjout;
    String? dateModif;
    SousRegion? sousRegion;
  Pays({
    this.idPays,
    required this.codePays,
    required this.nomPays,
    required this.descriptionPays,
    this.personneModif,
    required this.statutPays,
    this.dateAjout,
    this.libelleNiveau1Pays,
    this.libelleNiveau2Pays,
    this.libelleNiveau3Pays,
    this.monnaie,
    this.whattsAppPays,
    this.dateModif,
    required this.sousRegion,
  });

  // Pays copyWith({
  //   String? idPays,
  //   String? codePays,
  //   String? nomPays,
  //   String? descriptionPays,
  //   String? personneModif,
  //   bool? statutPays,
  //   String? dateAjout,
  //   String? libelleNiveau1Pays,
  //   String? libelleNiveau2Pays,
  //   String? libelleNiveau3Pays,
  //   String? monnaie,
  //   String? tauxDollar,
  //   String? tauxYuan,
  //   String? dateModif,
  //   SousRegion? sousRegion,
  // }) {
  //   return Pays(
  //     idPays: idPays ?? this.idPays,
  //     codePays: codePays ?? this.codePays,
  //     nomPays: nomPays ?? this.nomPays,
  //     descriptionPays: descriptionPays ?? this.descriptionPays,
  //     personneModif: personneModif ?? this.personneModif,
  //     statutPays: statutPays ?? this.statutPays,
  //     dateAjout: dateAjout ?? this.dateAjout,
  //     libelleNiveau1Pays: libelleNiveau1Pays ?? this.libelleNiveau1Pays,
  //     libelleNiveau2Pays: libelleNiveau2Pays ?? this.libelleNiveau2Pays,
  //     libelleNiveau3Pays: libelleNiveau3Pays ?? this.libelleNiveau3Pays,
  //     dateModif: dateModif ?? this.dateModif,
  //     sousRegion: sousRegion ?? this.sousRegion,
  //   );
  // }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idPays': idPays,
      'codePays': codePays,
      'nomPays': nomPays,
      'descriptionPays': descriptionPays,
      'personneModif': personneModif,
      'statutPays': statutPays,
      'dateAjout': dateAjout,
      'libelleNiveau1Pays': libelleNiveau1Pays,
      'libelleNiveau2Pays': libelleNiveau2Pays,
      'libelleNiveau3Pays': libelleNiveau3Pays,
      'monnaie':monnaie,
      'whattsAppPays': whattsAppPays,
      'dateModif': dateModif,
      'sousRegion': sousRegion?.toMap(),
    };
  }

  factory Pays.fromMap(Map<String, dynamic> map) {
    return Pays(
      idPays: map['idPays'] != null ? map['idPays'] as String : null,
      codePays: map['codePays'] as String,
      nomPays: map['nomPays'] as String,
      descriptionPays: map['descriptionPays'] as String,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      statutPays: map['statutPays'] as bool,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      libelleNiveau1Pays: map['libelleNiveau1Pays'] != null ? map['libelleNiveau1Pays'] as String : null,
      libelleNiveau2Pays: map['libelleNiveau2Pays'] != null ? map['libelleNiveau2Pays'] as String : null,
      libelleNiveau3Pays: map['libelleNiveau3Pays'] != null ? map['libelleNiveau3Pays'] as String : null,
      monnaie: map['monnaie'] != null ? map['monnaie'] as String : null,
      whattsAppPays: map['whattsAppPays'] != null ? map['whattsAppPays'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      sousRegion: SousRegion.fromMap(map['sousRegion'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pays.fromJson(String source) => Pays.fromMap(json.decode(source) as Map<String, dynamic>);

 
}
