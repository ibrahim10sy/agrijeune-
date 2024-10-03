import 'dart:convert';

import 'package:koumi/models/Pays.dart';


class Niveau1Pays {
   String? idNiveau1Pays;
  final String? codeN1;
   String? nomN1;
  final String? descriptionN1;
  final bool? statutN1;
  final String? dateAjout;
  final String? dateModif;
  final Pays? pays;

  Niveau1Pays({
    this.idNiveau1Pays,
     this.codeN1,
     this.nomN1,
     this.descriptionN1,
     this.statutN1,
    this.dateAjout,
    this.dateModif,
     this.pays,
  });

  

  Niveau1Pays copyWith({
    String? idNiveau1Pays,
    String? codeN1,
    String? nomN1,
    String? descriptionN1,
    bool? statutN1,
    String? dateAjout,
    String? dateModif,
    Pays? pays,
  }) {
    return Niveau1Pays(
      idNiveau1Pays: idNiveau1Pays ?? this.idNiveau1Pays,
      codeN1: codeN1 ?? this.codeN1,
      nomN1: nomN1 ?? this.nomN1,
      descriptionN1: descriptionN1 ?? this.descriptionN1,
      statutN1: statutN1 ?? this.statutN1,
      dateAjout: dateAjout ?? this.dateAjout,
      dateModif: dateModif ?? this.dateModif,
      pays: pays ?? this.pays,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idNiveau1Pays': idNiveau1Pays,
      'codeN1': codeN1,
      'nomN1': nomN1,
      'descriptionN1': descriptionN1,
      'statutN1': statutN1,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'pays': pays?.toMap(),
    };
  }

  factory Niveau1Pays.fromMap(Map<String, dynamic> map) {
    return Niveau1Pays(
      idNiveau1Pays: map['idNiveau1Pays'] != null ? map['idNiveau1Pays'] as String : null,
      codeN1: map['codeN1'] as String,
      nomN1: map['nomN1'] as String,
      descriptionN1: map['descriptionN1'] as String,
      statutN1: map['statutN1'] as bool,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      pays: Pays.fromMap(map['pays'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Niveau1Pays.fromJson(String source) => Niveau1Pays.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Niveau1Pays(idNiveau1Pays: $idNiveau1Pays, codeN1: $codeN1, nomN1: $nomN1, descriptionN1: $descriptionN1, statutN1: $statutN1, dateAjout: $dateAjout, dateModif: $dateModif, pays: $pays)';
  }

  @override
  bool operator ==(covariant Niveau1Pays other) {
    if (identical(this, other)) return true;
  
    return 
      other.idNiveau1Pays == idNiveau1Pays &&
      other.codeN1 == codeN1 &&
      other.nomN1 == nomN1 &&
      other.descriptionN1 == descriptionN1 &&
      other.statutN1 == statutN1 &&
      other.dateAjout == dateAjout &&
      other.dateModif == dateModif &&
      other.pays == pays;
  }

  @override
  int get hashCode {
    return idNiveau1Pays.hashCode ^
      codeN1.hashCode ^
      nomN1.hashCode ^
      descriptionN1.hashCode ^
      statutN1.hashCode ^
      dateAjout.hashCode ^
      dateModif.hashCode ^
      pays.hashCode;
  }
}
