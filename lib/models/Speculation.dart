import 'dart:convert';

import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';

class Speculation {
  String? idSpeculation;
  final String? codeSpeculation;
  String? nomSpeculation;
  final String? descriptionSpeculation;
  final bool? statutSpeculation;
  final CategorieProduit? categorieProduit;
  final String? dateAjout;
  final String? dateModif;
  final String? personneModif;

  Speculation({
    this.idSpeculation,
    this.codeSpeculation,
    this.nomSpeculation,
    this.descriptionSpeculation,
    this.statutSpeculation,
    this.categorieProduit,
    this.dateAjout,
    this.dateModif,
    this.personneModif,
  });

  Speculation copyWith({
    String? idSpeculation,
    String? codeSpeculation,
    String? nomSpeculation,
    String? descriptionSpeculation,
    bool? statutSpeculation,
    CategorieProduit? categorieProduit,
    String? dateAjout,
    String? dateModif,
    String? personneModif,
  }) {
    return Speculation(
        idSpeculation: idSpeculation ?? this.idSpeculation,
        codeSpeculation: codeSpeculation ?? this.codeSpeculation,
        nomSpeculation: nomSpeculation ?? this.nomSpeculation,
        descriptionSpeculation:
            descriptionSpeculation ?? this.descriptionSpeculation,
        statutSpeculation: statutSpeculation ?? this.statutSpeculation,
        categorieProduit: categorieProduit ?? this.categorieProduit,
        dateAjout: dateAjout ?? this.dateAjout,
        dateModif: dateModif ?? this.dateModif,
        personneModif: personneModif ?? this.personneModif);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idSpeculation': idSpeculation,
      'codeSpeculation': codeSpeculation,
      'nomSpeculation': nomSpeculation,
      'descriptionSpeculation': descriptionSpeculation,
      'statutSpeculation': statutSpeculation,
      'categorieProduit': categorieProduit?.toMap(),
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'personneModif': personneModif,
    };
  }

  factory Speculation.fromMap(Map<String, dynamic> map) {
    return Speculation(
      idSpeculation: map['idSpeculation'] as String,
      codeSpeculation: map['codeSpeculation'] as String,
      nomSpeculation: map['nomSpeculation'] as String,
      descriptionSpeculation: map['descriptionSpeculation'] as String,
      statutSpeculation: map['statutSpeculation'] as bool,
      categorieProduit: map['categorieProduit'] != null
          ? CategorieProduit.fromMap(
              map['categorieProduit'] as Map<String, dynamic>)
          : null,
      dateAjout: map['dateAjout'] != null ? map['dateAjout'] as String : null,
      dateModif: map['dateModif'] != null ? map['dateModif'] as String : null,
      personneModif:
          map['personneModif'] != null ? map['personneModif'] as String : null,
    );
  }

  // String toJson() => json.encode(toMap());
  Map<String, dynamic> toJson() => {
        "idSpeculation": idSpeculation,
        "codeSpeculation": codeSpeculation,
        "nomSpeculation": nomSpeculation,
        "descriptionSpeculation": descriptionSpeculation,
        "statutSpeculation": statutSpeculation,
        "categorieProduit": categorieProduit?.toJson(),
        "dateAjout": dateAjout,
        "dateModif": dateModif,
        "personneModif": personneModif,
      };

  factory Speculation.fromJson(String source) =>
      Speculation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Speculation(idSpeculation: $idSpeculation, codeSpeculation: $codeSpeculation, nomSpeculation: $nomSpeculation, descriptionSpeculation: $descriptionSpeculation, statutSpeculation: $statutSpeculation, categorieProduit: $categorieProduit, dateAjout: $dateAjout, dateModif: $dateModif, personneModif: $personneModif)';
  }

  @override
  bool operator ==(covariant Speculation other) {
    if (identical(this, other)) return true;

    return other.idSpeculation == idSpeculation &&
        other.codeSpeculation == codeSpeculation &&
        other.nomSpeculation == nomSpeculation &&
        other.descriptionSpeculation == descriptionSpeculation &&
        other.statutSpeculation == statutSpeculation &&
        other.categorieProduit == categorieProduit &&
        other.dateAjout == dateAjout &&
        other.dateModif == dateModif &&
        other.personneModif == personneModif;
 
  }

  @override
  int get hashCode {
    return idSpeculation.hashCode ^
        codeSpeculation.hashCode ^
        nomSpeculation.hashCode ^
        descriptionSpeculation.hashCode ^
        statutSpeculation.hashCode ^
        categorieProduit.hashCode ^
        dateAjout.hashCode ^
        dateModif.hashCode ^
        personneModif.hashCode;
  }
}
