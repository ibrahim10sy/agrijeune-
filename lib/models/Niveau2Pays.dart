import 'dart:convert';

import 'package:koumi/models/Niveau1Pays.dart';


class Niveau2Pays {
 final String? idNiveau2Pays;
  final String codeN2;
  final String nomN2;
  final String? personneModif;
  final String descriptionN2;
  final bool statutN2;
  final String? dateAjout;
  final String? dateModif;
  final Niveau1Pays niveau1Pays;
  
  Niveau2Pays({
    this.idNiveau2Pays,
    required this.codeN2,
    required this.nomN2,
    this.personneModif,
    required this.descriptionN2,
    required this.statutN2,
    this.dateAjout,
    this.dateModif,
    required this.niveau1Pays,
  });

  Niveau2Pays copyWith({
    String? idNiveau2Pays,
    String? codeN2,
    String? nomN2,
    String? personneModif,
    String? descriptionN2,
    bool? statutN2,
    String? dateAjout,
    String? dateModif,
    Niveau1Pays? niveau1Pays,
  }) {
    return Niveau2Pays(
      idNiveau2Pays: idNiveau2Pays ?? this.idNiveau2Pays,
      codeN2: codeN2 ?? this.codeN2,
      nomN2: nomN2 ?? this.nomN2,
      personneModif: personneModif ?? this.personneModif,
      descriptionN2: descriptionN2 ?? this.descriptionN2,
      statutN2: statutN2 ?? this.statutN2,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      niveau1Pays: niveau1Pays ?? this.niveau1Pays,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idNiveau2Pays': idNiveau2Pays,
      'codeN2': codeN2,
      'nomN2': nomN2,
      'personneModif': personneModif,
      'descriptionN2': descriptionN2,
      'statutN2': statutN2,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'niveau1Pays': niveau1Pays.toMap(),
    };
  }

  factory Niveau2Pays.fromMap(Map<String, dynamic> map) {
    return Niveau2Pays(
      idNiveau2Pays: map['idNiveau2Pays'] != null ? map['idNiveau2Pays'] as String : null,
      codeN2: map['codeN2'] as String,
      nomN2: map['nomN2'] as String,
      personneModif: map['personneModif'] != null ? map['personneModif'] as String : null,
      descriptionN2: map['descriptionN2'] as String,
      statutN2: map['statutN2'] as bool,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      niveau1Pays: Niveau1Pays.fromMap(map['niveau1Pays'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Niveau2Pays.fromJson(String source) => Niveau2Pays.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Niveau2Pays(idNiveau2Pays: $idNiveau2Pays, codeN2: $codeN2, nomN2: $nomN2, personneModif: $personneModif, descriptionN2: $descriptionN2, statutN2: $statutN2, dateAjout: $dateAjout, dateModif: $dateModif, niveau1Pays: $niveau1Pays)';
  }

  @override
  bool operator ==(covariant Niveau2Pays other) {
    if (identical(this, other)) return true;
  
    return 
      other.idNiveau2Pays == idNiveau2Pays &&
      other.codeN2 == codeN2 &&
      other.nomN2 == nomN2 &&
      other.personneModif == personneModif &&
      other.descriptionN2 == descriptionN2 &&
      other.statutN2 == statutN2 &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.niveau1Pays == niveau1Pays;
  }

  @override
  int get hashCode {
    return idNiveau2Pays.hashCode ^
      codeN2.hashCode ^
      nomN2.hashCode ^
      personneModif.hashCode ^
      descriptionN2.hashCode ^
      statutN2.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      niveau1Pays.hashCode;
  }
}
